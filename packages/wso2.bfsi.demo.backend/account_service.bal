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
import ballerina/mime;

import wso2.bfsi.demo.backend.model;
import wso2.bfsi.demo.backend.repository;
import wso2.bfsi.demo.backend.util;

# Represents accounts API service methods.
public isolated class AccountService {

    private final repository:AccountsRepository repository = new ();

    # Get all accounts.
    #
    # + return - account list
    public isolated function getAccounts() returns model:AccountsResponse {
        return {
            Data: self.repository.getAllAccounts().toArray(),
            Links: self.getLinks("/accounts"),
            Meta: {TotalPages: 1}
        };
    }

    # Get an account by account ID.
    #
    # + accountId - the account ID path parameter, Try A001 as the default value
    # + return - account list or error
    public isolated function getAccount(string accountId) returns model:AccountsResponse|model:InvalidResourceIdError {
        if accountId == "" {
            log:printDebug(util:EMPTY_ACCOUNT_ID);
            return error(util:EMPTY_ACCOUNT_ID, ErrorCode = util:CODE_EMPTY_ACCOUNT_ID);
        }
        model:Account? account = self.repository.getAllAccounts()[accountId];
        if account == () {
            log:printDebug(util:INVALID_ACCOUNT_ID, accountId = accountId);
            return error(util:INVALID_ACCOUNT_ID, ErrorCode = util:CODE_INVALID_ACCOUNT_ID);
        }

        return {
            Data: account,
            Links: self.getLinks("/accounts", accountId),
            Meta: {TotalPages: 1}
        };
    }

    # Get all balances.
    #
    # + return - all balances or error
    public isolated function getBalances() returns model:BalanceResponse {
        return {
            Data: self.repository.getAllBalances().toArray(),
            Links: self.getLinks("/balances"),
            Meta: {TotalPages: 1}
        };
    }

    # Get balances by account ID.
    #
    # + accountId - the account ID path parameter, Try A001 as the default value
    # + return - account balances list or error
    public isolated function getAccountBalances(string accountId)
            returns model:BalanceResponse|model:InvalidResourceIdError {
        if accountId == "" {
            log:printDebug(util:EMPTY_ACCOUNT_ID);
            return error(util:EMPTY_ACCOUNT_ID, ErrorCode = util:CODE_EMPTY_ACCOUNT_ID);
        }
        model:Balance[] balances = from model:Balance i in self.repository.getAllBalances()
            where i.AccountId == accountId
            select i;

        return {
            Data: balances,
            Links: self.getLinks(string `/accounts/${accountId}/balances`),
            Meta: {TotalPages: 1}
        };
    }

    # Get all beneficiaries.
    #
    # + return - account beneficiaries list or error
    public isolated function getBeneficiaries() returns model:BeneficiariesResponse {
        return {
            Data: self.repository.getAllBeneficiaries().toArray(),
            Links: self.getLinks("/beneficiaries"),
            Meta: {TotalPages: 1}
        };
    }

    # Get beneficiaries by account ID.
    #
    # + accountId - the account ID path parameter, Try A001 as the default value
    # + return - account beneficiaries list or error
    public isolated function getAccountBeneficiaries(string accountId)
            returns model:BeneficiariesResponse|model:InvalidResourceIdError {
        if accountId == "" {
            log:printDebug(util:EMPTY_ACCOUNT_ID);
            return error(util:EMPTY_ACCOUNT_ID, ErrorCode = util:CODE_EMPTY_ACCOUNT_ID);
        }
        model:Beneficiary[] beneficiaries = from model:Beneficiary i in self.repository.getAllBeneficiaries()
            where i.AccountId == accountId
            select i;

        return {
            Data: beneficiaries,
            Links: self.getLinks(string `/accounts/${accountId}/beneficiaries`),
            Meta: {TotalPages: 1}
        };
    }

    # Get all direct debits.
    #
    # + return - account direct debits list or error
    public isolated function getDirectDebits() returns model:DirectDebitsResponse {
        return {
            Data: self.repository.getAllDirectDebits().toArray(),
            Links: self.getLinks("/direct-debits"),
            Meta: {TotalPages: 1}
        };
    }

    # Get direct debits by account ID.
    #
    # + accountId - the account ID path parameter, Try A001 as the default value
    # + return - account direct debits list or error
    public isolated function getAccountDirectDebits(string accountId)
            returns model:DirectDebitsResponse|model:InvalidResourceIdError {
        if accountId == "" {
            log:printDebug(util:EMPTY_ACCOUNT_ID);
            return error(util:EMPTY_ACCOUNT_ID, ErrorCode = util:CODE_EMPTY_ACCOUNT_ID);
        }
        model:DirectDebit[] directDebits = from model:DirectDebit i in self.repository.getAllDirectDebits()
            where i.AccountId == accountId
            select i;

        return {
            Data: directDebits,
            Links: self.getLinks(string `/accounts/${accountId}/direct-debits`),
            Meta: {TotalPages: 1}
        };
    }

    # Get all offers.
    #
    # + return - account offers list or error
    public isolated function getOffers() returns model:OffersResponse {
        return {
            Data: self.repository.getAllOffers().toArray(),
            Links: self.getLinks("/offers"),
            Meta: {TotalPages: 1}
        };
    }

    # Get offers by account ID.
    #
    # + accountId - the account ID path parameter, Try A001 as the default value
    # + return - account offers list or error
    public isolated function getAccountOffers(string accountId)
            returns model:OffersResponse|model:InvalidResourceIdError {
        if accountId == "" {
            log:printDebug(util:EMPTY_ACCOUNT_ID);
            return error(util:EMPTY_ACCOUNT_ID, ErrorCode = util:CODE_EMPTY_ACCOUNT_ID);
        }
        model:Offer[] offers = from model:Offer i in self.repository.getAllOffers()
            where i.AccountId == accountId
            select i;
        return {
            Data: offers,
            Links: self.getLinks(string `/accounts/${accountId}/offers`),
            Meta: {TotalPages: 1}
        };
    }

    # Get all parties.
    #
    # + return - account parties list or error
    public isolated function getParties() returns model:PartiesResponse {
        return {
            Data: self.repository.getAllParties().toArray(),
            Links: self.getLinks("/parties"),
            Meta: {TotalPages: 1}
        };
    }

    # Get parties by account ID.
    #
    # + accountId - the account ID path parameter, Try A001 as the default value
    # + return - account parties list or error
    public isolated function getAccountParties(string accountId)
            returns model:PartiesResponse|model:InvalidResourceIdError {
        if accountId == "" {
            log:printDebug(util:EMPTY_ACCOUNT_ID);
            return error(util:EMPTY_ACCOUNT_ID, ErrorCode = util:CODE_EMPTY_ACCOUNT_ID);
        }
        model:Party[] parties = [];
        foreach model:Party party in self.repository.getAllParties().toArray() {
            model:PartyRelationship pr = <model:PartyRelationship>party.Relationships;
            model:PartyRelationshipAccount pra = <model:PartyRelationshipAccount>pr.Account;
            if (pra.Id == accountId) {
                parties.push(party);
            }
        }
        return {
            Data: parties,
            Links: self.getLinks(string `/accounts/${accountId}/parties`),
            Meta: {TotalPages: 1}
        };
    }

    # Get a party by account ID.
    #
    # + accountId - the account ID path parameter, Try A001 as the default value
    # + return - account parties list or error
    public isolated function getAccountParty(string accountId)
            returns model:PartiesResponse|model:InvalidResourceIdError {
        if accountId == "" {
            log:printDebug(util:EMPTY_ACCOUNT_ID);
            return error(util:EMPTY_ACCOUNT_ID, ErrorCode = util:CODE_EMPTY_ACCOUNT_ID);
        }
        foreach model:Party party in self.repository.getAllParties().toArray() {
            model:PartyRelationship pr = <model:PartyRelationship>party.Relationships;
            model:PartyRelationshipAccount pra = <model:PartyRelationshipAccount>pr.Account;
            if pra.Id == accountId {
                return {
                    Data: party,
                    Links: self.getLinks(string `/accounts/${accountId}/party`),
                    Meta: {TotalPages: 1}
                };
            }
        }
        return error(util:INVALID_ACCOUNT_ID, ErrorCode = util:CODE_INVALID_ACCOUNT_ID);
    }

    # Get all products.
    #
    # + return - account products list or error
    public isolated function getProducts() returns model:ProductsResponse {
        return {
            Data: self.repository.getAllProducts().toArray(),
            Links: self.getLinks("/products"),
            Meta: {TotalPages: 1}
        };
    }

    # Get products by account ID.
    #
    # + accountId - the account ID path parameter, Try A001 as the default value
    # + return - account products list or error
    public isolated function getAccountProducts(string accountId)
            returns model:ProductsResponse|model:InvalidResourceIdError {
        if accountId == "" {
            log:printDebug(util:EMPTY_ACCOUNT_ID);
            return error(util:EMPTY_ACCOUNT_ID, ErrorCode = util:CODE_EMPTY_ACCOUNT_ID);
        }
        model:Product[] product = from model:Product i in self.repository.getAllProducts()
            where i.AccountId == accountId
            select i;
        return {
            Data: product,
            Links: self.getLinks(string `/accounts/${accountId}/products`),
            Meta: {TotalPages: 1}
        };
    }

    # Get all scheduled payments.
    #
    # + return - account scheduled payments list or error
    public isolated function getScheduledPayments() returns model:ScheduledPaymentsResponse {
        return {
            Data: self.repository.getAllScheduledPayments().toArray(),
            Links: self.getLinks("/scheduled-payments"),
            Meta: {TotalPages: 1}
        };
    }

    # Get scheduled payments by account ID.
    #
    # + accountId - the account ID path parameter, Try A001 as the default value
    # + return - account scheduled payments list or error
    public isolated function getAccountScheduledPayments(string accountId)
            returns model:ScheduledPaymentsResponse|model:InvalidResourceIdError {
        if accountId == "" {
            log:printDebug(util:EMPTY_ACCOUNT_ID);
            return error(util:EMPTY_ACCOUNT_ID, ErrorCode = util:CODE_EMPTY_ACCOUNT_ID);
        }
        model:ScheduledPayment[] scheduledPayments = from model:ScheduledPayment
            i in self.repository.getAllScheduledPayments()
            where i.AccountId == accountId
            select i;
        return {
            Data: scheduledPayments,
            Links: self.getLinks(string `/accounts/${accountId}/scheduled-payments`),
            Meta: {TotalPages: 1}
        };
    }

    # Get all standing orders.
    #
    # + return - account standing orders list or error
    public isolated function getStandingOrders() returns model:StandingOrdersResponse {
        return {
            Data: self.repository.getAllStandingOrders().toArray(),
            Links: self.getLinks("/standing-orders"),
            Meta: {TotalPages: 1}
        };
    }

    # Get standing orders by account ID.
    #
    # + accountId - the account ID path parameter, Try A001 as the default value
    # + return - account standing orders list or error
    public isolated function getAccountStandingOrders(string accountId)
            returns model:StandingOrdersResponse|model:InvalidResourceIdError {
        if accountId == "" {
            log:printDebug(util:EMPTY_ACCOUNT_ID);
            return error(util:EMPTY_ACCOUNT_ID, ErrorCode = util:CODE_EMPTY_ACCOUNT_ID);
        }
        model:StandingOrder[] standingOrder = from model:StandingOrder i in self.repository.getAllStandingOrders()
            where i.AccountId == accountId
            select i;
        return {
            Data: standingOrder,
            Links: self.getLinks(string `/accounts/${accountId}/standing-orders`),
            Meta: {TotalPages: 1}
        };
    }

    # Get all statements.
    #
    # + return - account statements list or error
    public isolated function getStatements() returns model:StatementsResponse {
        return {
            Data: self.repository.getAllStatements().toArray(),
            Links: self.getLinks("/statements"),
            Meta: {TotalPages: 1}
        };
    }

    # Get statements by account ID.
    #
    # + accountId - the account ID path parameter, Try A001 as the default value
    # + return - account statements list or error
    public isolated function getAccountStatements(string accountId)
            returns model:StatementsResponse|model:InvalidResourceIdError {
        if accountId == "" {
            log:printDebug(util:EMPTY_ACCOUNT_ID);
            return error(util:EMPTY_ACCOUNT_ID, ErrorCode = util:CODE_EMPTY_ACCOUNT_ID);
        }
        model:Statement[] statement = from model:Statement i in self.repository.getAllStatements()
            where i.AccountId == accountId
            select i;

        return {
            Data: statement,
            Links: self.getLinks(string `/accounts/${accountId}/statement`),
            Meta: {TotalPages: 1}
        };
    }

    # Get statements by account ID and statement ID.
    #
    # + accountId - the account ID path parameter, Try A001 as the default value
    # + statementId - the statement ID path parameter, Try S001 as the default value
    # + return - account statements list or error
    public isolated function getAccountStatement(string accountId, string statementId)
            returns model:StatementsResponse|model:InvalidResourceIdError {
        if accountId == "" {
            log:printDebug(util:EMPTY_ACCOUNT_ID);
            return error(util:EMPTY_ACCOUNT_ID, ErrorCode = util:CODE_EMPTY_ACCOUNT_ID);
        } else if statementId == "" {
            log:printDebug(util:EMPTY_STATEMENT_ID);
            return error(util:EMPTY_STATEMENT_ID, ErrorCode = util:CODE_EMPTY_STATEMENT_ID);
        }
        model:Statement? statement = self.repository.getAllStatements()[accountId, statementId];
        if statement == () {
            log:printDebug(util:INVALID_STATEMENT_ID, statementId = statementId);
            return error(util:INVALID_STATEMENT_ID, ErrorCode = util:CODE_INVALID_STATEMENT_ID);
        }
        return {
            Data: statement,
            Links: self.getLinks(string `/accounts/${accountId}/statement`, statementId),
            Meta: {TotalPages: 1}
        };
    }

    # Get the statement file by account ID and statement ID.
    #
    # + accountId - the account ID path parameter, Try A001 as the default value
    # + statementId - the statement ID path parameter, Try S001 as the default value
    # + return - account statements list or error
    public isolated function getAccountStatementFile(string accountId, string statementId)
            returns http:Response|model:InvalidResourceIdError {
        if accountId == "" {
            log:printDebug(util:EMPTY_ACCOUNT_ID);
            return error(util:EMPTY_ACCOUNT_ID, ErrorCode = util:CODE_EMPTY_ACCOUNT_ID);
        } else if statementId == "" {
            log:printDebug(util:EMPTY_STATEMENT_ID);
            return error(util:EMPTY_STATEMENT_ID, ErrorCode = util:CODE_EMPTY_STATEMENT_ID);
        }
        model:Statement? statement = self.repository.getAllStatements()[accountId, statementId];
        if statement == () {
            log:printDebug(util:INVALID_STATEMENT_ID, statementId = statementId);
            return error(util:INVALID_STATEMENT_ID, ErrorCode = util:CODE_INVALID_STATEMENT_ID);
        } else {
            return self.readStatementFile(statement);
        }
    }

    private isolated function readStatementFile(model:Statement statement) returns http:Response {
        // Creates an enclosing entity.
        mime:Entity entity = new;
        http:Response outResponse = new;
        // todo: file read from resources directory is not possible yet. 
        // @see https://github.com/ballerina-platform/ballerina-spec/issues/1100
        // This file path is relative to where the Ballerina is running.
        // entity.setFileAsEntityBody(util:PATH_STATEMENT_FILE, contentType = mime:APPLICATION_PDF);

        // Creates an array to hold the parent part and set it to the response.
        outResponse.setBodyParts([entity], contentType = mime:MULTIPART_FORM_DATA);
        outResponse.setHeader("Content-Disposition",
            "attachment; filename=statement_" + statement.StatementId + ".pdf");
        return outResponse;
    }

    # Get all transactions.
    #
    # + return - account transactions list or error
    public isolated function getTransactions() returns model:TransactionsResponse {
        return {
            Data: self.repository.getAllTransactions().toArray(),
            Links: self.getLinks("/transactions"),
            Meta: {TotalPages: 1}
        };
    }

    # Get transactions by account ID.
    #
    # + accountId - the account ID path parameter, Try A001 as the default value
    # + return - account transactions list or error
    public isolated function getAccountTransactions(string accountId)
            returns model:TransactionsResponse|model:InvalidResourceIdError {
        if accountId == "" {
            log:printDebug(util:EMPTY_ACCOUNT_ID);
            return error(util:EMPTY_ACCOUNT_ID, ErrorCode = util:CODE_EMPTY_ACCOUNT_ID);
        }
        model:Transaction[] transactions = from model:Transaction i in self.repository.getAllTransactions()
            where i.AccountId == accountId
            select i;

        return {
            Data: transactions,
            Links: self.getLinks(string `/accounts/${accountId}/transactions`),
            Meta: {TotalPages: 1}
        };
    }

    # Get transactions by account ID and statement ID.
    #
    # + accountId - the account ID path parameter, Try A001 as the default value
    # + statementId - the statement ID path parameter, Try S001 as the default value
    # + return - account transactions list or error
    public isolated function getAccountAndStatementTransactions(string accountId, string statementId)
            returns model:TransactionsResponse|model:InvalidResourceIdError {
        if accountId == "" {
            log:printDebug(util:EMPTY_ACCOUNT_ID);
            return error(util:EMPTY_ACCOUNT_ID, ErrorCode = util:CODE_EMPTY_ACCOUNT_ID);
        }
        model:Transaction[] AccountTransactions = from model:Transaction i in self.repository.getAllTransactions()
            where i.AccountId == accountId
            select i;

        model:Transaction[] transactions = AccountTransactions.filter(tran =>
            !(tran.StatementReference is ()) && ((<string[]>tran?.StatementReference).indexOf(statementId, 0) != ()));

        return {
            Data: transactions,
            Links: self.getLinks(string `/accounts/${accountId}/statement/${statementId}/transactions`),
            Meta: {TotalPages: 1}
        };
    }

    # Get the Link matching to the path and consent id
    #
    # + path - Path of the request
    # + id - Consent Id of the request
    # + return - Link
    private isolated function getLinks(string path, string id = "") returns model:Links {
        return {Self: string `https://api.alphabank.com/open-banking/v3.1/aisp${path}/${id}`};
    }
}
