// Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/io;
import ballerina/log;
import ballerina/time;
import ballerinax/financial.iso20022.cash_management as camtIsoRecord;
import ballerinax/financial.iso20022.payment_initiation as painIsoRecord;
import ballerinax/financial.iso20022.payments_clearing_and_settlement as pacsIsoRecord;
import ballerina/uuid;
import ballerina/regex;

configurable Monitoring monitoring = ?;

# Description.
#
# + orgnlMessage - original message  
# + transMessage - translated message  
# + msgId - message ID
# + direction - message direction
# + mtmsgType - MT message type
# + mxMsgType - MX message type 
# + currency - currency used in the transaction
# + amount - transaction amount
# + errorMsg - error message
public function logMessage(string orgnlMessage, string transMessage, string msgId,string direction, string mtmsgType,
    string mxMsgType, string currency, string amount, string errorMsg = "") {

    if monitoring.logging.enabled {
        // modify this to log into a file or a central log management system
        error? logResult = logToFile(orgnlMessage, transMessage, msgId, direction, mtmsgType, mxMsgType, currency,
            amount, errorMsg);
        if logResult is error {
            handleLogFailure(logResult);
        }
    }

}


function logToFile(string orgnlMessage, string transMessage, string msgId,string direction, string mtmsgType,
    string mxMsgType, string currency, string amount, string errorMsg = "") returns error? {
    // Create values for the JSON object
    time:Utc currentTime = time:utcNow();
    time:Civil civilTime = time:utcToCivil(currentTime);
    string timestamp = check time:civilToString(civilTime);
    
    // Create the JSON log entry
    json logEntry = {
        "msgId": msgId,
        "mtMsgType": mtmsgType,
        "mxMsgType": mxMsgType,
        "currency": currency,
        "amount": amount,
        "timestamp": timestamp,
        "direction": direction,
        "transMessage": transMessage,
        "orgnlMessage": orgnlMessage,
        "fieldError":errorMsg.includes("required") ? errorMsg : "",
        "notSupportedError": errorMsg.toLowerAscii().includes("not supported") ? errorMsg : "",
        "invalidError": errorMsg.toLowerAscii().includes("invalid") && !errorMsg.toLowerAscii().includes("not supported")? errorMsg : "",
        "otherError": !errorMsg.includes("required") && !errorMsg.includes("not supported")
            && !errorMsg.toLowerAscii().includes("invalid") ? errorMsg : ""
    };
    
    // Convert to JSON string and append newline
    string jsonLogString = logEntry.toJsonString() + "\n";
    
    // Write to file
    io:FileWriteOption option = "APPEND";
    string filePath;
    if direction.toLowerAscii() == "inward" {
        filePath = monitoring.logging.inwardFilePath;
    } else if direction.toLowerAscii() == "outward" {
        filePath = monitoring.logging.outwardFilePath;
    } else {
        log:printError("Invalid message direction", direction = direction);
        return error("Invalid message direction");
    }
    check io:fileWriteString(filePath, jsonLogString, option);
}

function handleLogFailure(error e) {
    log:printError("[MT <-> MX Translator] Error while logging", err = e.toBalString());
}

function getMxMessageType(xml xmlContent) returns string|error {
    xml:Element document = xml `<Empty/>`;
    foreach xml:Element element in xmlContent.elementChildren() {
        if element.getName().includes("Document") {
            document = element;
        }
    }
    map<string> attributeMap = (document).getAttributes();
    foreach string attributeKey in attributeMap.keys() {
        if attributeKey.includes("xmlns") {
            foreach string recordKey in isoMessageTypes.keys() {
                string? nameSpace = attributeMap[attributeKey];
                if nameSpace is string && nameSpace.includes(recordKey) {
                    int index = check nameSpace.indexOf(recordKey).ensureType();
                    return nameSpace.substring(index);
                }
            }
        }
    }
    return "unknown";
}

function getTransactionCcyAndAmnt(record {} swiftMessage) returns [string, string] {
    string|error ccy = "";
    string|error amnt = "";

    foreach string mtField in MT_TRANS_AMNT_FIELD {
        ccy = (<record {}>(<record {}>(<record {}>swiftMessage["block4"])[string `${mtField}`])["Ccy"])["content"].ensureType();
        amnt = (<record {}>(<record {}>(<record {}>swiftMessage["block4"])[string `${mtField}`])["Amnt"])["content"].ensureType();
    }

    if ccy is string && amnt is string {
        return [ccy, regex:replace(amnt, "\\,", ".")];
    }
    if ccy is error && amnt is string{
        return ["N/A", regex:replace(amnt, "\\,", ".")];
    }
    if amnt is error && ccy is string {
        return [ccy, "N/A"];
    }
    return ["N/A", "N/A"];
}

function getmtMessageId(record {} mtRecord) returns string {
    string|error mtMsgId = (<record {}>(<record {}>(<record {}>mtRecord["block4"])["MT20"])["msgId"])["content"].ensureType();
    string msgId = "";
    if mtMsgId is error {
        msgId = uuid:createRandomUuid().toString();
        log:printWarn(string `Error occurred while getting the message ID. Generating random ID.`, msgId = msgId);
    } else {
        msgId = mtMsgId;
    }
    return msgId;
}

function getMessageDirection(record {} mtRecord) returns string {
    string|error direction = (<record {}>mtRecord["block2"])["'type"].ensureType();
    if direction is string {
        direction = direction.startsWith("O") ? "Outward" : "Inward";
    }
    return direction is error ? "Outward" : direction;
}

function getMtMessageInfo(string message) returns [string, string, string, string, string]|error {
    [string, string, string, string, string] [msgId, msgType, msgDirection, msgCcy, msgAmnt] = [];

    foreach string msgTyp in MT_MESSAGE_NAMES {
        if message.includes("2:I" + msgTyp.substring(0, 3)) || message.includes("2:O" + msgTyp.substring(0, 3)) {
            msgDirection = message.includes("2:O") ? "Outward" : "Inward";
            if msgTyp.length() > 3 && message.includes("119:"+ msgTyp.substring(3)) {
                msgType = msgTyp;
                break;
            }
            msgType = msgTyp.substring(0, 3); 
        }
    }

    if message.includes(":20:") {
        int index = check message.indexOf(":20:").ensureType(int);
        msgId = message.substring(index + 4, check message.indexOf("\n", index).ensureType(int));
    } else {
        msgId = uuid:createRandomUuid().toString();
        log:printWarn(string `Error occurred while getting the message ID. Generating random ID.`, msgId = msgId);
    }

    foreach string mtField in MT_TRANS_AMNT_FIELD {
        if message.includes(":" + mtField.substring(2) + ":") {
            int index = check message.indexOf(":" + mtField.substring(2) + ":").ensureType(int);
            if mtField == "MT32B" {
                msgCcy = message.length() > index + 7 ? message.substring(index + 5, index + 8) : "N/A";
                msgAmnt = message.length() > index + 8 ? message.substring(index + 8,
                    check message.indexOf("\n", index).ensureType(int)) : "N/A";
                break;
            }
            msgCcy = message.length() > index + 14 ? message.substring(index + 11, index + 14) : "N/A";
            msgAmnt = message.length() > index + 14 ? message.substring(index + 14,
                check message.indexOf("\n", index).ensureType(int)) : "N/A";
        }
    }

    return [msgId, msgType, msgDirection, msgCcy, regex:replace(msgAmnt, "\\,", ".")];  
}


# Monitoring record that define the monitoring configurations.
# 
# + logging - logging configurations
type Monitoring record {|
   Logging logging;
|};

# Logging record that define the logging configurations.
#
# + enabled - boolean field to enable or disable the logging  
# + inwardFilePath - file path to store the logs of inward messages
# + outwardFilePath - file path to store the logs of outward messages
type Logging record {|
    boolean enabled;
    string inwardFilePath;
    string outwardFilePath;
|};

final readonly & map<typedesc<record {}>> isoMessageTypes = {
    "pacs.002": pacsIsoRecord:Pacs002Envelope,
    "pacs.003": pacsIsoRecord:Pacs003Envelope,
    "pacs.004": pacsIsoRecord:Pacs004Envelope,
    "pacs.008": pacsIsoRecord:Pacs008Envelope,
    "pacs.009": pacsIsoRecord:Pacs009Envelope,
    "pacs.010": pacsIsoRecord:Pacs010Envelope,
    "pain.001": painIsoRecord:Pain001Envelope,
    "pain.008": painIsoRecord:Pain008Envelope,
    "camt.026": camtIsoRecord:Camt026Envelope,
    "camt.027": camtIsoRecord:Camt027Envelope,
    "camt.028": camtIsoRecord:Camt028Envelope,
    "camt.029": camtIsoRecord:Camt029Envelope,
    "camt.031": camtIsoRecord:Camt031Envelope,
    "camt.033": camtIsoRecord:Camt033Envelope,
    "camt.034": camtIsoRecord:Camt034Envelope,
    "camt.050": camtIsoRecord:Camt050Envelope,
    "camt.052": camtIsoRecord:Camt052Envelope,
    "camt.053": camtIsoRecord:Camt053Envelope,
    "camt.054": camtIsoRecord:Camt054Envelope,
    "camt.055": camtIsoRecord:Camt055Envelope,
    "camt.056": camtIsoRecord:Camt056Envelope,
    "camt.057": camtIsoRecord:Camt057Envelope,
    "camt.060": camtIsoRecord:Camt060Envelope,
    "camt.105": camtIsoRecord:Camt105Envelope,
    "camt.106": camtIsoRecord:Camt106Envelope,
    "camt.107": camtIsoRecord:Camt107Envelope,
    "camt.108": camtIsoRecord:Camt108Envelope,
    "camt.109": camtIsoRecord:Camt109Envelope
};

const MT_MESSAGE_NAMES = [
    "101", "102", "102STP", "103", "103STP", "103REMIT", "104", "107","110", "111", "112", "190", "191", "192", "195",
    "196", "199", "200", "201", "202", "202COV", "203", "204", "205", "205COV", "210", "290", "291", "292", "295",
    "296", "299", "900", "910", "920", "940", "941", "942", "950", "970", "971", "972", "973", "990", "991", "992", "995",
    "996", "999"];

const MT_TRANS_AMNT_FIELD = ["MT32A", "MT32B", "MT32C", "MT32D"];
