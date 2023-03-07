// Copyright (c) 2023, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.

// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein is strictly forbidden, unless permitted by WSO2 in accordance with
// the WSO2 Software License available at: https://wso2.com/licenses/eula/3.2
// For specific language governing the permissions and limitations under
// this license, please see the license as well as any agreement you’ve
// entered into with WSO2 governing the purchase of this software and any
// associated services.

import ballerina/constraint;
import wso2.bfsi.demo.backend.util;

# The Initiation payload is sent by the initiating party to the bank. It is used to request movement of funds using 
# a payment file.
public type FilePaymentInitiation record {|
    # Specifies the payment file type.
    string FileType;
    # A base64 encoding of a SHA256 hash of the file to be uploaded.
    @constraint:String {maxLength: 44, minLength: 1}
    string FileHash;
    # Reference for the file.
    @constraint:String {maxLength: 40, minLength: 1}
    string FileReference?;
    # Number of individual transactions contained in the payment information group.
    string NumberOfTransactions?;
    # Total of all individual amounts included in the group, irrespective of currencies.
    decimal ControlSum?;
    # Date at which the initiating party requests the clearing agent to process the payment. 
    # Usage: This is the date on which the debtor's account is to be debited.All dates in the JSON payloads are 
    # represented in ISO 8601 date-time format. All date-time fields in responses must include the timezone. 
    # An example is below: 2017-04-05T10:43:07+00:00
    string RequestedExecutionDateTime?;
    # User community specific instrument.
    #
    # Usage: This element is used to specify a local instrument, local clearing option and/or further qualify the 
    # service or service level.
    string LocalInstrument?;
    # Unambiguous identification of the account of the debtor to which a debit entry will be made as a 
    # result of the transaction.
    DebtorAccount DebtorAccount?;
    # Information supplied to enable the matching of an entry with the items that the transfer is intended to settle, 
    # such as commercial invoices in an accounts' receivable system.
    RemittanceInformation RemittanceInformation?;
    # Additional information that can not be captured in the structured fields and/or any other specific block.
    Object SupplementaryData?;
|};

# Represents a file payment request payload.
public type FilePaymentRequest record {|
    # Represents data of the file payment request.
    FilePaymentData Data;
|};

# Represents data of the file payment request.
public type FilePaymentData record {|
    # OB: Unique identification as assigned by the bank to uniquely identify the consent resource.
    @constraint:String {maxLength: 128, minLength: 1}
    string ConsentId;
    # The Initiation payload is sent by the initiating party to the bank. It is used to request movement of funds 
    # using a payment file.
    FilePaymentInitiation Initiation;
|};

# Set of elements used to define the file payment response.
public type FilePaymentResponse record {|
    # Data object File Payment Response
    FilePaymentsResponseData Data;
    # Links relevant to the payload
    Links Links?;
    # Meta Data relevant to the payload
    Meta Meta?;
|};

# Represents data of the file payment response.
public type FilePaymentsResponseData record {|
    # OB: Unique identification as assigned by the bank to uniquely identify the file payment resource.
    @constraint:String {maxLength: 40, minLength: 1}
    string FilePaymentId;
    # OB: Unique identification as assigned by the bank to uniquely identify the consent resource.
    @constraint:String {maxLength: 128, minLength: 1}
    string ConsentId;
    # Date and time at which the message was created.All dates in the JSON payloads are represented in 
    # ISO 8601 date-time format. All date-time fields in responses must include the timezone. An example is below:
    # 2017-04-05T10:43:07+00:00
    string CreationDateTime = util:getPastDateTime();
    # Specifies the status of the payment order resource.
    string Status;
    # Date and time at which the resource status was updated.All dates in the JSON payloads are represented in 
    # ISO 8601 date-time format. All date-time fields in responses must include the timezone. An example is below:
    # 2017-04-05T10:43:07+00:00
    string StatusUpdateDateTime = util:getPastDateTime();
    # Set of elements used to provide details of a charge for the payment initiation.
    DataCharges[] Charges?;
    # The Initiation payload is sent by the initiating party to the bank. It is used to request movement of funds 
    # using a payment file.
    FilePaymentInitiation Initiation;
    # The multiple authorisation flow response from the bank.
    MultiAuthorisation MultiAuthorisation?;
    # ^ Only incuded in the response if `Data. ReadRefundAccount` is set to `Yes` in the consent.
    CreditorAccount Debtor?;
|};
