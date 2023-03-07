// Copyright (c) 2023, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.

// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein is strictly forbidden, unless permitted by WSO2 in accordance with
// the WSO2 Software License available at: https://wso2.com/licenses/eula/3.2
// For specific language governing the permissions and limitations under
// this license, please see the license as well as any agreement you’ve
// entered into with WSO2 governing the purchase of this software and any
// associated services.

import wso2.bfsi.demo.backend.model;
    
#Creates a `Accounts` table type in which each member is uniquely identified using its `AccountId` field.
public table<model:Account> key(AccountId) accounts = table[
    {AccountId: "A001", Status: "Enabled", AccountType: "Personal", AccountSubType: "Current Account"},
    {AccountId: "A002", Status: "Enabled", AccountType: "Personal", AccountSubType: "Savings Account"},
    {AccountId: "A003", Status: "Disabled", AccountType: "Personal", AccountSubType: "Joint Account"}
];
