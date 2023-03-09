// Copyright (c) 2023, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.

// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein is strictly forbidden, unless permitted by WSO2 in accordance with
// the WSO2 Software License available at: https://wso2.com/licenses/eula/3.2
// For specific language governing the permissions and limitations under
// this license, please see the license as well as any agreement you’ve
// entered into with WSO2 governing the purchase of this software and any
// associated services.

import ballerina/time;
import ballerina/regex;

const ipv4 = "(([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])";
const ipv6 = "((([0-9a-fA-F]){1,4})\\:){7}([0-9a-fA-F]){1,4}";
const uuid = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$";

# This class is used to define the header validations
public isolated class HeaderValidator {

    public isolated function validateAuthHeader(string authHeader) returns error? {
        if (authHeader == "") {
            // This header is optional. hence, return true
            return ();
        }

        time:Utc currentTime = time:utcNow();
        time:Utc timeInHeader;
        do {
            timeInHeader = check time:utcFromString(authHeader);
        } on fail var e {
            return error(e.message());
        }
        time:Seconds seconds = time:utcDiffSeconds(currentTime, timeInHeader);

        if seconds > 0d {
            return ();
        } else {
            return error("Invalid Date found in the header");
        }
    }
        
    public isolated function validateIpAddress(string ipAddress) returns error? {
        if (ipAddress == "") {
            // This header is optional. hence, return true
            return ();
        }

        boolean isIpv4 = regex:matches(ipAddress, ipv4);
        boolean isIpv6 = regex:matches(ipAddress, ipv6);

        if isIpv4 || isIpv6 {
            return ();
        } else {
            return error("Found invalid ip address in headers");
        }
    }

    public isolated function validateUUID(string uuidHeader) returns error? {
        if (uuidHeader == "") {
            // This header is optional. hence, return true
            return ();
        }

        boolean isUuid = regex:matches(uuidHeader, uuid);
        return isUuid ? () : error("Found invalid UUID in headers");
    }
}
