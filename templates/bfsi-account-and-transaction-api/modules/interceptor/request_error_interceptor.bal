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

import bfsi_account_and_transaction_api.model;
import bfsi_account_and_transaction_api.util;

# The `RequestErrorInterceptor` service class implementation. 
# Allows intercepting the error that occurred in the request path and handle it accordingly.
public isolated service class RequestErrorInterceptor {
    *http:RequestErrorInterceptor;

    // The error occurred in the interceptor execution can be accessed by the mandatory argument: `error`.
    resource isolated function 'default [string... path](error err) returns model:BadRequest {
        // In this case, all of the errors are sent as `400 BadRequest` responses with a customized media type and body. 
        log:printError("Invalid request: ", err);
        model:BadRequest errorResponse = constructDefaultErrorResponse(err);

        if err is model:InvalidHeaderError {
            errorResponse.body.ErrorCode = err.detail()?.ErrorCode;
            errorResponse.body.Message = err.message();
        }
        return errorResponse;
    }
}

# Returns a default error response.
#
# + err - The error to be processed
# + return - The default error response
public isolated function constructDefaultErrorResponse(error err) returns model:BadRequest => {
    mediaType: "application/org+json",
    body: {
        ErrorCode: util:CODE_INTERNAL_SERVER_ERROR,
        Message: err.message()
    }
};
