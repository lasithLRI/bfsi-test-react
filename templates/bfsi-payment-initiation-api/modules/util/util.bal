// Copyright (c) 2023, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.

// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein is strictly forbidden, unless permitted by WSO2 in accordance with
// the WSO2 Software License available at: https://wso2.com/licenses/eula/3.2
// For specific language governing the permissions and limitations under
// this license, please see the license as well as any agreement you’ve
// entered into with WSO2 governing the purchase of this software and any
// associated services.

import ballerina/http;
import ballerina/log;
import ballerina/random;
import ballerina/time;
import ballerina/uuid;
import bfsi_payment_initiation_api.model;

# + return - current date and time.
public isolated function getDateTime() returns string {
    return time:utcToString(time:utcNow());
}

# + return - future date and time.
public isolated function getFutureDateTime() returns string {    
    return time:utcToString(time:utcAddSeconds(time:utcNow(), generateRandomSeconds()));
}

# + return - past date and time.
public isolated function getPastDateTime() returns string {
    return time:utcToString(time:utcAddSeconds(time:utcNow(), generateRandomSeconds(true)));
}

# + isNegative - if true, return a negative random time in seconds.
# + return - a random time in seconds.
isolated function generateRandomSeconds(boolean isNegative=false) returns time:Seconds {
    int randomSeconds;
    do {
	    randomSeconds = check random:createIntInRange(86400, 864000);
    } on fail var e {
        log:printDebug("failed to generate a random integer. Caused by, ", e);
    	randomSeconds = 86400;
    }

    return isNegative ? <time:Seconds>(randomSeconds * -1) : <time:Seconds>randomSeconds;
}

# + return - a random amount.
public isolated function getRandomAmount() returns string {
    return (random:createDecimal() * 1000).toFixedString(2);
}

# + return - a random UUID.
public isolated function getRandomId() returns string {
    return uuid:createType4AsString();
}

public type ErrorModel record {
    string ErrorCode;
};

# Get Domestic Payment Initiation payload.
# 
# + return - a domestic payment initiation payload.
public isolated function getDomesticPaymentInitiation() returns json {
    map<json> DOMESTIC_PAYMENT_INITIATION = { 
        "InstructionIdentification": "ACME412",
        "EndToEndIdentification": "FRESCO.21302.GFX.20", 
        "InstructedAmount": { 
            "Amount": "165.88", 
            "Currency": "GBP" 
        }, 
        "CreditorAccount": {  
            "SchemeName": "UK.OBIE.SortCodeAccountNumber",  
            "Identification": "08080021325698",  
            "Name": "ACME Inc",  
            "SecondaryIdentification": "0002"
        },  
        "RemittanceInformation": {   
            "Reference": "FRESCO-101",  
            "Unstructured": "Internal ops code 5120101"  
        }  
    };

    return DOMESTIC_PAYMENT_INITIATION;
}

# Get Domestic scheduled Payment Initiation payload.
# 
# + return - a domestic scheduled payment initiation payload.
public isolated function getDomesticScheduledPaymentInitiation() returns json {
    map<json> DOMESTIC_SCHEDULED_PAYMENT_INITIATION = {
        "InstructionIdentification": "89f0a53a91ee47f6a383536f851d6b5a",
        "RequestedExecutionDateTime": "2018-08-06T00:00:00+00:00",
        "InstructedAmount": {
            "Amount": "200.00",
            "Currency": "GBP"
        },
        "DebtorAccount": {
            "SchemeName": "UK.OBIE.SortCodeAccountNumber",
            "Identification": "11280001234567",
            "Name": "Andrea Frost"
        },
        "CreditorAccount": {
            "SchemeName": "UK.OBIE.SortCodeAccountNumber",
            "Identification": "08080021325698",
            "Name": "Tom Kirkman"
        },
        "RemittanceInformation": {
            "Reference": "DSR-037",
            "Unstructured": "Internal ops code 5120103"
        }
    };

    return DOMESTIC_SCHEDULED_PAYMENT_INITIATION;
}

# Get Domestic standing order Payment Initiation payload.
# 
# + return - a domestic standing order payment initiation payload.
public isolated function getDomesticStandingOrderPaymentInitiation() returns json {
    map<json> DOMESTIC_STANDING_ORDER_INITIATION = {
        "Frequency": "EvryDay",
        "Reference": "Pocket money for Damien",
        "FirstPaymentDateTime": "2023-06-06T06:06:06+00:00",
        "FirstPaymentAmount": {
            "Amount": "6.66",
            "Currency": "GBP"
        },
        "RecurringPaymentAmount": {
            "Amount": "7.00",
            "Currency": "GBP"
        },
        "FinalPaymentDateTime": "2025-06-06T06:06:06+00:00",
        "FinalPaymentAmount": {
            "Amount": "7.00",
            "Currency": "GBP"
        },
        "DebtorAccount": {
            "SchemeName": "UK.OBIE.SortCodeAccountNumber",
            "Identification": "11280001234567",
            "Name": "Andrea Smith"
        },
        "CreditorAccount": {
            "SchemeName": "UK.OBIE.SortCodeAccountNumber",
            "Identification": "08080021325698",
            "Name": "Bob Clements"
        }
    };

    return DOMESTIC_STANDING_ORDER_INITIATION;
}

# Get a file payment initiation payload.
# 
# + return - a file payment initiation payload.
public isolated function getFilePaymentInitiation() returns json {
    map<json> FILE_PAYMENT_INITIATION = {
        "FileType": "UK.OBIE.pain.001.001.08",
        "FileHash": "m5ah/h1UjLvJYMxqAoZmj9dKdjZnsGNm+yMkJp/KuqQ",
        "FileReference": "GB2OK238",
        "NumberOfTransactions": "100",
        "ControlSum": 3459.30
    };

    return FILE_PAYMENT_INITIATION;
}

# Get a International payment initiation payload.
# 
# + return - an international payment initiation payload.
public isolated function getInternationalPaymentInitiation() returns json {
    map<json> INTERNATIONAL_PAYMENT_INITIATION = {
        "InstructionIdentification": "ACME412",
        "EndToEndIdentification": "FRESCO.21302.GFX.20",
        "InstructionPriority": "Normal",
        "CurrencyOfTransfer": "USD",
        "InstructedAmount": {
            "Amount": "165.88",
            "Currency": "GBP"
        },
        "CreditorAccount": {
            "SchemeName": "UK.OBIE.SortCodeAccountNumber",
            "Identification": "08080021325698",
            "Name": "ACME Inc",
            "SecondaryIdentification": "0002"
        },
        "RemittanceInformation": {
            "Reference": "FRESCO-101",
            "Unstructured": "Internal ops code 5120101"
        },
        "ExchangeRateInformation": {
            "UnitCurrency": "GBP",
            "RateType": "Actual"
        }
    };

    return INTERNATIONAL_PAYMENT_INITIATION;
}

# Get the international scheduled payment initiation payload.
# 
# + return - an international scheduled payment initiation payload.
public isolated function getInternatioanlScheduledPaymentInitiation() returns json {
    map<json> INTERNATIONAL_SCHEDULED_INITIATION = {
        "InstructionIdentification": "ACME412",
        "EndToEndIdentification": "FRESCO.21302.GFX.20",
        "RequestedExecutionDateTime": "2023-06-06T06:06:06+00:00",
        "InstructedAmount": {
            "Amount": "165.88",
            "Currency": "USD"
        },
        "CurrencyOfTransfer":"USD",
        "CreditorAccount": {
            "SchemeName": "UK.OBIE.SortCodeAccountNumber",
            "Identification": "08080021325698",
            "Name": "ACME Inc",
            "SecondaryIdentification": "0002"
        },
        "RemittanceInformation": {
            "Reference": "FRESCO-101",
            "Unstructured": "Internal ops code 5120101"
        },
        "ExchangeRateInformation": {
            "UnitCurrency": "GBP",
            "RateType": "Actual"
        }
    };

    return INTERNATIONAL_SCHEDULED_INITIATION;
}

# Get the international standing order payment initiation payload.
# 
# + return - an international standing order payment initiation payload.
public isolated function getInternatioanlStandingOrderPaymentInitiation() returns json {
    map<json> INTERNATIONAL_STANDING_ORDER_INITIATION = {
        "Frequency": "EvryWorkgDay",
        "FirstPaymentDateTime": "2023-06-06T06:06:06+00:00",
        "FinalPaymentDateTime": "2025-06-06T06:06:06+00:00",
        "DebtorAccount": {
            "SchemeName": "UK.OBIE.SortCodeAccountNumber",
            "Identification": "11280001234567",
            "Name": "Andrea Frost"
        },
        "CreditorAccount": {
            "SchemeName": "UK.OBIE.IBAN",
            "Identification": "DE89370400440532013000",
            "Name": "Tom Kirkman"
        },
        "InstructedAmount": {
            "Amount": "20",
            "Currency": "EUR"
        },
        "CurrencyOfTransfer":"EUR"
    };

    return INTERNATIONAL_STANDING_ORDER_INITIATION;
}

public isolated function extractCreditorAccount(anydata payload, string path) returns model:CreditorAccount|error {

    if (path.includes("domestic-payment")) {
        model:DomesticPaymentInitiation initiation = check extractDomesticPaymentInitiation(payload);
        model:CreditorAccount creditorAcc = check initiation.CreditorAccount.cloneWithType(model:CreditorAccount);
        return creditorAcc;

    } else if (path.includes("domestic-scheduled-payment")) {
        model:DomesticScheduledPaymentInitiation initiation = check extractDomesticScheduledPaymentInitiation(payload);
        model:CreditorAccount creditorAcc = check initiation.CreditorAccount.cloneWithType(model:CreditorAccount);
        return creditorAcc;

    } else if (path.includes("domestic-standing-order")) {
        model:DomesticStandingOrderInitiation initiation = check extractDomesticStandingOrderInitiation(payload);
        model:CreditorAccount creditorAcc = check initiation.CreditorAccount.cloneWithType(model:CreditorAccount);
        return creditorAcc;

    } else if (path.includes("international-payment")) {
        model:InternationalPaymentInitiation initiation = check extractInternationalPaymentInitiation(payload);
        model:CreditorAccount creditorAcc = check initiation.CreditorAccount.cloneWithType(model:CreditorAccount);
        return creditorAcc;

    } else if (path.includes("international-scheduled-payment")) {
        model:InternationalScheduledPaymentInitiation initiation = check extractInternationalScheduledPaymentInitiation(payload);
        model:CreditorAccount creditorAcc = check initiation.CreditorAccount.cloneWithType(model:CreditorAccount);
        return creditorAcc;

    } else if (path.includes("international-standing-orders")) {
        model:InternationalStandingOrderInitiation initiation = check extractInternationalStandingOrderInitiation(payload);
        model:CreditorAccount creditorAcc = check initiation.CreditorAccount.cloneWithType(model:CreditorAccount);
        return creditorAcc;

    } else {
        return error("Invalid path", ErrorCode = "UK.OBIE.Field.Invalid");
    }
}

public isolated function extractDebtorAccount(anydata payload, string path) returns model:DebtorAccount|error|() {

    if (path.includes("domestic-payment")) {
        model:DomesticPaymentInitiation initiation = check extractDomesticPaymentInitiation(payload);
        if (initiation.DebtorAccount is ()) {
            return ();
        }
        model:DebtorAccount debtorAccount = check initiation.DebtorAccount.cloneWithType(model:DebtorAccount);
        return debtorAccount;

    } else if (path.includes("domestic-scheduled-payment")) {
        model:DomesticScheduledPaymentInitiation initiation = check extractDomesticScheduledPaymentInitiation(payload);
        if (initiation.DebtorAccount is ()) {
            return ();
        }
        model:DebtorAccount debtorAccount = check initiation.DebtorAccount.cloneWithType(model:DebtorAccount);
        return debtorAccount;

    } else if (path.includes("domestic-standing-order")) {
        model:DomesticStandingOrderInitiation initiation = check extractDomesticStandingOrderInitiation(payload);
        if (initiation.DebtorAccount is ()) {
            return ();
        }
        model:DebtorAccount debtorAccount = check initiation.DebtorAccount.cloneWithType(model:DebtorAccount);
        return debtorAccount;

    } else if (path.includes("international-payment")) {
        model:InternationalPaymentInitiation initiation = check extractInternationalPaymentInitiation(payload);
        if (initiation.DebtorAccount is ()) {
            return ();
        }
        model:DebtorAccount debtorAccount = check initiation.DebtorAccount.cloneWithType(model:DebtorAccount);
        return debtorAccount;

    } else if (path.includes("international-scheduled-payment")) {
        model:InternationalScheduledPaymentInitiation initiation = check extractInternationalScheduledPaymentInitiation(payload);
        if (initiation.DebtorAccount is ()) {
            return ();
        }
        model:DebtorAccount debtorAccount = check initiation.DebtorAccount.cloneWithType(model:DebtorAccount);
        return debtorAccount;

    } else if (path.includes("international-standing-order")) {
        model:InternationalStandingOrderInitiation initiation = check extractInternationalStandingOrderInitiation(payload);
        if (initiation.DebtorAccount is ()) {
            return ();
        }
        model:DebtorAccount debtorAccount = check initiation.DebtorAccount.cloneWithType(model:DebtorAccount);
        return debtorAccount;

    } else if (path.includes("file-payment")) {
        model:FilePaymentInitiation initiation = check extractFilePaymentInitiation(payload);
        if (initiation.DebtorAccount is ()) {
            return ();
        }
        model:DebtorAccount debtorAccount = check initiation.DebtorAccount.cloneWithType(model:DebtorAccount);
        return debtorAccount;
        
    } else {
        return error("Invalid path", ErrorCode ="UK.OBIE.Field.Invalid");
    }
}

public isolated function extractDomesticPaymentInitiation(anydata payload) returns model:DomesticPaymentInitiation|error {
    model:DomesticPaymentRequest request = check payload.cloneWithType(model:DomesticPaymentRequest);
    model:DomesticPaymentRequestData data = check request.Data.cloneWithType(model:DomesticPaymentRequestData);
    model:DomesticPaymentInitiation initiation = check data.Initiation.cloneWithType(model:DomesticPaymentInitiation);
    
    return initiation;
}

public isolated function extractDomesticScheduledPaymentInitiation(anydata payload) returns model:DomesticScheduledPaymentInitiation|error {
    model:DomesticScheduledPaymentRequest request = check payload.cloneWithType(model:DomesticScheduledPaymentRequest);
    model:DomesticScheduledPaymentData data = check request.Data.cloneWithType(model:DomesticScheduledPaymentData);
    model:DomesticScheduledPaymentInitiation initiation = check data.Initiation.cloneWithType(model:DomesticScheduledPaymentInitiation);
        
    return initiation;
}

public isolated function extractDomesticStandingOrderInitiation(anydata payload) returns model:DomesticStandingOrderInitiation|error {
    model:DomesticStandingOrderRequest request = check payload.cloneWithType(model:DomesticStandingOrderRequest);
    model:DomesticStandingOrderData data = check request.Data.cloneWithType(model:DomesticStandingOrderData);
    model:DomesticStandingOrderInitiation initiation = check data.Initiation.cloneWithType(model:DomesticStandingOrderInitiation);
        
    return initiation;
}

public isolated function extractInternationalPaymentInitiation(anydata payload) returns model:InternationalPaymentInitiation|error {
    model:InternationalPaymentRequest request = check payload.cloneWithType(model:InternationalPaymentRequest);
    model:InternationalPaymentData data = check request.Data.cloneWithType(model:InternationalPaymentData);
    model:InternationalPaymentInitiation initiation = check data.Initiation.cloneWithType(model:InternationalPaymentInitiation);
        
    return initiation;
}

public isolated function extractInternationalScheduledPaymentInitiation(anydata payload) returns model:InternationalScheduledPaymentInitiation|error {
    model:InternationalScheduledPaymentRequest request = check payload.cloneWithType(model:InternationalScheduledPaymentRequest);
    model:InternationalScheduledPaymentData data = check request.Data.cloneWithType(model:InternationalScheduledPaymentData);
    model:InternationalScheduledPaymentInitiation initiation = check data.Initiation.cloneWithType(model:InternationalScheduledPaymentInitiation);
        
    return initiation;
}

public isolated function extractInternationalStandingOrderInitiation(anydata payload) returns model:InternationalStandingOrderInitiation|error {
    model:InternationalStandingOrderRequest request = check payload.cloneWithType(model:InternationalStandingOrderRequest);
    model:InternationalStandingOrderData data = check request.Data.cloneWithType(model:InternationalStandingOrderData);
    model:InternationalStandingOrderInitiation initiation = check data.Initiation.cloneWithType(model:InternationalStandingOrderInitiation);
    return initiation;
}

public isolated function extractFilePaymentInitiation(anydata payload) returns model:FilePaymentInitiation|error {
    model:FilePaymentRequest request = check payload.cloneWithType(model:FilePaymentRequest);
    model:FilePaymentData data = check request.Data.cloneWithType(model:FilePaymentData);
    model:FilePaymentInitiation initiation = check data.Initiation.cloneWithType(model:FilePaymentInitiation);
    
    return initiation;
}

# Represents a subtype of BAD_REQUEST error
public type BadRequest record {|
    *http:BadRequest;

    # Open Banking error format
    record {
        # Low level texual error code
        string ErrorCode;
        # Description of the error occured
        string Message;
        # Recommended but optional reference to the JSON Path of the field with error
        string Path?;
        # URL to help remediate the problem, or provide more information, or to API Reference, or help etc
        string Url?;
    } body;
|};
