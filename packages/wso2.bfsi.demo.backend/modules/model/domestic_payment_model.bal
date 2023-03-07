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
# the debtor account to a creditor for a single domestic payment.
public type DomesticPaymentInitiation record {|
    # Unique identification as assigned by an instructing party for an instructed party to unambiguously identify 
    # the instruction.
    # Usage: the  instruction identification is a point to point reference that can be used between the instructing 
    # party and the instructed party to refer to the individual instruction. It can be included in several messages 
    # related to the instruction.
    @constraint:String {maxLength: 35, minLength: 1}
    string InstructionIdentification;
    # Unique identification assigned by the initiating party to unambiguously identify the transaction. 
    # This identification is passed on, unchanged, throughout the entire end-to-end chain.
    #
    # `Usage:` The end-to-end identification can be used for reconciliation or to link tasks relating to the 
    # transaction. It can be included in several messages related to the transaction.
    #
    # `OB:` The Faster Payments Scheme can only access 31 characters for the EndToEndIdentification field.
    @constraint:String {maxLength: 35, minLength: 1}
    string EndToEndIdentification;
    # User community specific instrument.
    # Usage: This element is used to specify a local instrument, local clearing option and/or further qualify the 
    # service or service level.
    string LocalInstrument?;
    # Amount of money to be moved between the debtor and creditor, before deduction of charges, expressed in the 
    # currency as ordered by the initiating party.
    # Usage: This amount has to be transported unchanged through the transaction chain.
    Amount InstructedAmount;
    # Unambiguous identification of the account of the debtor to which a debit entry will be made as a result of 
    # the transaction.
    DebtorAccount DebtorAccount?;
    # Unambiguous identification of the account of the creditor to which a credit entry will be posted as a 
    # result of the payment transaction.
    CreditorAccount CreditorAccount;
    # Information that locates and identifies a specific address, as defined by postal services.
    PostalAddress CreditorPostalAddress?;
    # Information supplied to enable the matching of an entry with the items that the transfer is intended to settle, 
    # such as commercial invoices in an accounts' receivable system.
    RemittanceInformation RemittanceInformation?;
    # Additional information that can not be captured in the structured fields and/or any other specific block.
    Object SupplementaryData?;
|};

# Information supplied to enable the matching of an entry with the items that the transfer is intended to settle, 
# such as commercial invoices in an accounts' receivable system.
public type RemittanceInformation record {|
    # Information supplied to enable the matching/reconciliation of an entry with the items that the payment is 
    # intended to settle, such as commercial invoices in an accounts' receivable system, in an unstructured form.
    @constraint:String {maxLength: 140, minLength: 1}
    string Unstructured?;
    # Unique reference, as assigned by the creditor, to unambiguously refer to the payment transaction.
    #
    # `Usage:` If available, the initiating party should provide this reference in the structured remittance 
    # information, to enable reconciliation by the creditor upon receipt of the amount of money.
    # If the business context requires the use of a creditor reference or a payment remit identification, and only one 
    # identifier can be passed through the end-to-end chain, the creditor's reference or payment remittance 
    # identification should be quoted in the end-to-end transaction identification.
    #
    # `OB:` The Faster Payments Scheme can only accept 18 characters for the ReferenceInformation field - 
    # which is where this ISO field will be mapped.
    @constraint:String {maxLength: 35, minLength: 1}
    string Reference?;
|};

# Represents a domestic pament intitiation request payload.
public type DomesticPaymentRequest record {|
    # Represents data of the domestic pament intitiation request
    DomesticPaymentRequestData Data;
    # The Risk section is sent by the initiating party to the bank.
    # It is used to specify additional details for risk scoring for Payments.
    Risk Risk;
|};

# Represents data of the domestic pament intitiation request.
public type DomesticPaymentRequestData record {|
    # OB: Unique identification as assigned by the bank to uniquely identify the consent resource.
    @constraint:String {maxLength: 128, minLength: 1}
    readonly string ConsentId;
    # The Initiation payload is sent by the initiating party to the bank. It is used to request movement of funds 
    # from the debtor account to a creditor for a single domestic payment.
    DomesticPaymentInitiation Initiation;
|};

# The Risk section is sent by the initiating party to the bank.
# It is used to specify additional details for risk scoring for Payments.
public type Risk record {|
    # Specifies the payment context
    # * BillPayment - @deprecated
    # * EcommerceGoods - @deprecated
    # * EcommerceServices - @deprecated
    # * Other - @deprecated
    # * PartyToParty - @deprecated
    string PaymentContextCode?;
    # Category code conform to ISO 18245, related to the type of services or goods the merchant provides for 
    # the transaction.
    @constraint:String {maxLength: 4, minLength: 3}
    string MerchantCategoryCode?;
    # The unique customer identifier of the user with the merchant.
    @constraint:String {maxLength: 70, minLength: 1}
    string MerchantCustomerIdentification?;
    # Indicates if Payee has a contractual relationship with the TPP.
    boolean ContractPresentInidicator?;
    # Indicates if TPP has immutably prepopulated payment details in for the user.
    boolean BeneficiaryPrepopulatedIndicator?;
    # Category code, related to the type of services or goods that corresponds to the underlying purpose of the 
    # payment that conforms to Recommended Purpose Code in ISO 20022 Payment Messaging List
    @constraint:String {maxLength: 4, minLength: 3}
    string PaymentPurposeCode?;
    # Specifies the extended type of account.
    string BeneficiaryAccountType?;
    # Information that locates and identifies a specific address,
    # as defined by postal services or in free format text.
    PostalAddress DeliveryAddress?;
|};

# Represents the payload of the domestic payment response.
public type DomesticPaymentResponse record {|
    # Data object Domestic Payment Response
    DomesticPaymentResponseData Data;
    # Links relevant to the payload
    Links Links?;
    # Meta Data relevant to the payload
    Meta Meta?;
|};

# Represents the data inside the payload of the domestic payment response.
public type DomesticPaymentResponseData record {|
    # OB: Unique identification as assigned by the bank to uniquely identify the domestic payment resource.
    @constraint:String {maxLength: 40, minLength: 1}
    string DomesticPaymentId;
    # OB: Unique identification as assigned by the bank to uniquely identify the consent resource.
    @constraint:String {maxLength: 128, minLength: 1}
    string ConsentId;
    # Date and time at which the message was created.All dates in the JSON payloads are represented in ISO 8601 
    # date-time format. All date-time fields in responses must include the timezone. An example is below:
    # 2017-04-05T10:43:07+00:00
    string CreationDateTime = util:getPastDateTime();
    # Specifies the status of the payment information group.
    string Status;
    # Date and time at which the resource status was updated.All dates in the JSON payloads are represented in ISO 8601
    # date-time format. All date-time fields in responses must include the timezone. An example is below:
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
    # The Initiation payload is sent by the initiating party to the bank. It is used to request movement of funds from 
    # the debtor account to a creditor for a single domestic payment.
    DomesticPaymentInitiation Initiation;
    # The multiple authorisation flow response from the bank.
    MultiAuthorisation MultiAuthorisation?;
    # ^ Only incuded in the response if `Data. ReadRefundAccount` is set to `Yes` in the consent.
    CreditorAccount Debtor?;
|};

# Unambiguous identification of the refund account to which a refund will be made as a result of the transaction.
public type DataRefund record {|
    # Provides the details to identify an account.
    CreditorAccount Account;
|};

# Set of elements used to provide details of a charge for the payment initiation.
public type DataCharges record {|
    # Specifies which party/parties will bear the charges associated with the processing of the payment transaction.
    string ChargeBearer;
    # Charge type, in a coded form.
    string Type;
    # Amount of money associated with the charge type.
    Amount Amount;
|};

# The multiple authorisation flow response from the bank.
public type MultiAuthorisation record {|
    # Specifies the status of the authorisation flow in code form.
    string Status;
    # Number of authorisations required for payment order 
    # (total required at the start of the multi authorisation journey).
    int NumberRequired?;
    # Number of authorisations received.
    int NumberReceived?;
    # Last date and time at the authorisation flow was updated.All dates in the JSON payloads are represented in 
    # ISO 8601 date-time format. All date-time fields in responses must include the timezone. An example is below:
    # 2017-04-05T10:43:07+00:00
    string LastUpdateDateTime?;
    # Date and time at which the requested authorisation flow must be completed.All dates in the JSON payloads are 
    # represented in ISO 8601 date-time format. All date-time fields in responses must include the timezone. 
    # An example is below: 2017-04-05T10:43:07+00:00
    string ExpirationDateTime?;
|};
