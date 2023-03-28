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

# `ResponseErrorInterceptor` intercepts the response and process the errors before it is dispatched to the client.
public isolated service class ResponseErrorInterceptor {
    *http:ResponseErrorInterceptor;

    remote isolated function interceptResponseError(error err) returns model:BadRequest {
        log:printError("Response generation failed: ", err);
        model:BadRequest errorResponse = constructDefaultErrorResponse(err);

        if err is model:InvalidResourceIdError {
            errorResponse.body.ErrorCode = err.detail()?.ErrorCode;
            errorResponse.body.Message = err.message();
        }
        return errorResponse;
    }
}
