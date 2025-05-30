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

import ballerina/file;
import ballerina/ftp;
import ballerina/io;
import ballerina/log;
import ballerinax/financial.iso20022ToSwiftmt as mxToMt;
import ballerinax/financial.swift.mt as swiftmt;

const DEFAULT = "Unknown";

configurable string listenerName = "Listener 1";
configurable string hostname = "127.0.0.1";
configurable int port = 23;
configurable string username = "ajai";
configurable string password = "pass";

configurable string mxfilepath = "/mx/";
configurable string mxfileNamePattern = "(.*).xml";
configurable decimal pollingInterval = 1;
configurable string backupFilePath = "/backup/";
configurable string outputFilePath = "/output/";

ftp:AuthConfiguration ftpListenerAuthConfig = username == "" ? {} :
    {credentials: {username: username, password: password}};

// Creates the listener with the connection parameters and the protocol-related
// configuration. The listener listens to the files
// with the given file name pattern located in the specified path.
listener ftp:Listener mxFileListener = new ({
    host: hostname,
    port: port,
    auth: ftpListenerAuthConfig,
    path: mxfilepath,
    fileNamePattern: mxfileNamePattern,
    pollingInterval: pollingInterval
});

// One or many services can listen to the SFTP listener for the
// periodically-polled file related events.
service on mxFileListener {

    // When a file event is successfully received, the `onFileChange` method is called.
    remote function onFileChange(ftp:WatchEvent & readonly event, ftp:Caller caller) returns error? {

        // `addedFiles` contains the paths of the newly-added files/directories after the last polling was called.
        foreach ftp:FileInfo addedFile in event.addedFiles {

            log:printDebug(string `[FTP MX Listner - ${listenerName}] File received: ${addedFile.name}`);
            // Get the newly added file from the SFTP server as a `byte[]` stream.
            stream<byte[] & readonly, io:Error?> fileStream = check caller->get(addedFile.pathDecoded);
            // Delete the file from the SFTP server after reading.
            check caller->delete(addedFile.pathDecoded);

            // copy to local file system
            check io:fileWriteBlocksFromStream(string `./temp/${addedFile.name}`, fileStream);
            check fileStream.close();

            // performs a read operation to read the lines as an array.
            xml inputXml = check io:fileReadXml(string `./temp/${addedFile.name}`);
            string mxMsgType = check getMxMessageType(inputXml);

            record {}|error mtRecord = mxToMt:toSwiftMtMessage(inputXml);
            if mtRecord is error {
                logMessage(inputXml.toBalString(), "", DEFAULT, DEFAULT, DEFAULT, mxMsgType, DEFAULT, DEFAULT, mtRecord.toBalString());
                log:printError("Error occurred while converting the ISO20022 message to SWIFT MT message.");
                return mtRecord;
            }

            string msgId = getmtMessageId(mtRecord);
            string mtMsgType = check (<record {}>mtRecord["block2"])["messageType"].ensureType();
            string|error validationFlag = (<record {}>(<record {}>mtRecord["block3"])["ValidationFlag"])["value"].ensureType();
            if validationFlag is string {
                mtMsgType = mtMsgType + validationFlag;
            }
            string msgDirection = getMessageDirection(mtRecord);
            [string, string] [msgCcy, msgAmnt] = getTransactionCcyAndAmnt(mtRecord);

            log:printDebug("ISO20022 message converted to SWIFT MT message successfully.");
            string|error finMessage = swiftmt:toFinMessage(mtRecord);
            if finMessage is error {
                log:printError("Error occurred while getting the FIN message.");
                logMessage(inputXml.toBalString(), "", msgId, msgDirection, mtMsgType, mxMsgType, msgCcy, msgAmnt, finMessage.toBalString());
                return finMessage;
            } else {
                logMessage(inputXml.toBalString(), finMessage, msgId, msgDirection, mtMsgType, mxMsgType, msgCcy, msgAmnt);
                string outputFileName = string `/result_${addedFile.name.substring(0, addedFile.name.length() - 4)}_${msgId}.txt`;
                check fileClient->put(outputFilePath + outputFileName, finMessage);
            }
            // remove temporary file
            check file:remove(string `./temp/${addedFile.name}`);
            // Write the content to a file.
            check caller->put(backupFilePath + msgId + "_" + addedFile.name, inputXml);
        }
    }

    function init() {
        log:printDebug(string `[FTP MX Listner - ${listenerName}] Listener started.`);
    }
}

ftp:Client fileClient = check new ({
    host: hostname,
    auth: ftpListenerAuthConfig,
    port: port
});
