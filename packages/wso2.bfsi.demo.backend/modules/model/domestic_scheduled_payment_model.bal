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

# The Initiation payload is sent by the initiating party to the bank. It is used to request movement of funds from 
# the debtor account to a creditor for a single scheduled domestic payment.
public type DomesticScheduledPaymentInitiation record {|
    # Unique identification as assigned by an instructing party for an instructed party to unambiguously identify the 
    # instruction.
    #
    # Usage: the  instruction identification is a point to point reference that can be used between the instructing 
    # party and the instructed party to refer to the individual instruction. It can be included in several messages 
    # related to the instruction.
    @constraint:String {maxLength: 35, minLength: 1}
    string InstructionIdentification;
    # Unique identification assigned by the initiating party to unambiguously identify the transaction. 
    # This identification is passed on, unchanged, throughout the entire end-to-end chain.
    #
    # Usage: The end-to-end identification can be used for reconciliation or to link tasks relating to the transaction. 
    # It can be included in several messages related to the transaction.
    #
    # OB: The Faster Payments Scheme can only access 31 characters for the EndToEndIdentification field.
    @constraint:String {maxLength: 35, minLength: 1}
    string EndToEndIdentification?;
    # User community specific instrument.
    #
    # Usage: This element is used to specify a local instrument, local clearing option and/or further qualify the 
    # service or service level.
    string LocalInstrument?;
    # Date at which the initiating party requests the clearing agent to process the payment. 
    # Usage: This is the date on which the debtor's account is to be debited.All dates in the JSON payloads are 
    # represented in ISO 8601 date-time format. All date-time fields in responses must include the timezone. 
    # An example is below: 2017-04-05T10:43:07+00:00
    string RequestedExecutionDateTime = util:getFutureDateTime();
    # Amount of money to be moved between the debtor and creditor, before deduction of charges, expressed in the 
    # currency as ordered by the initiating party.
    #
    # Usage: This amount has to be transported unchanged through the transaction chain.
    Amount InstructedAmount;
    # Unambiguous identification of the account of the debtor to which a debit entry will be made as a result of 
    # the transaction.
    DebtorAccount DebtorAccount?;
    # Unambiguous identification of the account of the creditor to which a credit entry will be posted as a result 
    # of the payment transaction.
    CreditorAccount CreditorAccount;
    # Information that locates and identifies a specific address, as defined by postal services.
    PostalAddress CreditorPostalAddress?;
    # Information supplied to enable the matching of an entry with the items that the transfer is intended to settle, 
    # such as commercial invoices in an accounts' receivable system.
    RemittanceInformation RemittanceInformation?;
    # Additional information that can not be captured in the structured fields and/or any other specific block.
    Object SupplementaryData?;
|};

# Represents a domestic scheduled payment request payload.
public type DomesticScheduledPaymentRequest record {|
    # Represents data of the domestic scheduled payment intitiation request.
    DomesticScheduledPaymentData Data;
    # The Risk section is sent by the initiating party to the bank.
    # It is used to specify additional details for risk scoring for Payments.
    Risk Risk;
|};

# Represents data of the domestic scheduled payment intitiation request.
public type DomesticScheduledPaymentData record {|
    # OB: Unique identification as assigned by the bank to uniquely identify the consent resource.
    @constraint:String {maxLength: 128, minLength: 1}
    string ConsentId;
    # The Initiation payload is sent by the initiating party to the bank. It is used to request movement of funds 
    # from the debtor account to a creditor for a single scheduled domestic payment.
    DomesticScheduledPaymentInitiation Initiation;
|};

# Represents the payload of the domestic scheduled payment response.
public type DomesticScheduledPaymentResponse record {|
    # Data object Domestic Scheduled Payment Response
    DomesticScheduledPaymentsResponseData Data;
    # Links relevant to the payload
    Links Links?;
    # Meta Data relevant to the payload
    Meta Meta?;
|};

# Represents the data inside the payload of the domestic scheduled payment response.
public type DomesticScheduledPaymentsResponseData record {|
    # OB: Unique identification as assigned by the bank to uniquely identify the domestic schedule payment resource.
    @constraint:String {maxLength: 40, minLength: 1}
    string DomesticScheduledPaymentId;
    # OB: Unique identification as assigned by the bank to uniquely identify the consent resource.
    @constraint:String {maxLength: 128, minLength: 1}
    string ConsentId;
    # Date and time at which the message was created.All dates in the JSON payloads are represented in ISO 8601 
    # date-time format. All date-time fields in responses must include the timezone. An example is below:
    # 2017-04-05T10:43:07+00:00
    string CreationDateTime = util:getPastDateTime();
    # Specifies the status of the payment order resource.
    string Status;
    # Date and time at which the resource status was updated.All dates in the JSON payloads are represented in 
    # ISO 8601 date-time format. All date-time fields in responses must include the timezone. An example is below:
    # 2017-04-05T10:43:07+00:00
    string StatusUpdateDateTime = util:getPastDateTime();
    # Expected execution date and time for the payment resource.All dates in the JSON payloads are represented in 
    # ISO 8601 date-time format. All date-time fields in responses must include the timezone. An example is below:
    # 2017-04-05T10:43:07+00:00
    string ExpectedExecutionDateTime?;
    # Expected settlement date and time for the payment resource.All dates in the JSON payloads are represented in 
    # ISO 8601 date-time format. All date-time fields in responses must include the timezone. An example is below:
    # 2017-04-05T10:43:07+00:00
    string ExpectedSettlementDateTime?;
    # Unambiguous identification of the refund account to which a refund will be made as a result of the transaction.
    DataRefund Refund?;
    # Set of elements used to provide details of a charge for the payment initiation.
    DataCharges[] Charges?;
    # The Initiation payload is sent by the initiating party to the bank. It is used to request movement of funds 
    # from the debtor account to a creditor for a single scheduled domestic payment.
    DomesticScheduledPaymentInitiation Initiation;
    # The multiple authorisation flow response from the bank.
    MultiAuthorisation MultiAuthorisation?;
    # ^ Only incuded in the response if `Data. ReadRefundAccount` is set to `Yes` in the consent.
    CreditorAccount Debtor?;
|};
