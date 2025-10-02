/**
 * Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com).
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

import "./hero-section.css"
import {QuickActionButton} from "../../components/forms/quick-action-button.jsx";
import PayBillsIcon from "/public/resources/assets/images/icons/pay_icon.svg?react"
import TransferFundsIcon from "/public/resources/assets/images/icons/transfer_icon.svg?react"
import ScheduleIcon from "/public/resources/assets/images/icons/schedule_icon.svg?react"
import ManagePayeeIcon from "/public/resources/assets/images/icons/payees_icon.svg?react"

const onclickAction = () => {
    console.log("Quick action QuickActionButton clicked");
}

const quickActionsButtons = [
    {icon: PayBillsIcon, name: "Pay Bills", onClick: onclickAction},
    {icon: TransferFundsIcon, name: "Transfer", onClick: onclickAction},
    {icon: ScheduleIcon, name: "Schedule", onClick: onclickAction},
    {icon: ManagePayeeIcon, name: "Payees", onClick: onclickAction}
];

/**
 * Renders the primary header or "hero" content for a product page.
 * * This component:
 * 1. Displays a **personalized greeting** based on the current time of day (Morning, Afternoon, or Evening).
 * 2. Shows the user's **name and profile image**.
 * 3. Renders a static set of **quick action buttons** (Pay Bills, Transfer, Schedule, Payees)
 * by mapping over the `quickActionsButtons` array and using the reusable `QuickActionButton` component.
 * 4. Displays a "Loading...." message while the `userInfo` prop is not yet available.
 * * @param {Object} props - The component props.
 * @param {Object} props.userInfo - The user information object, expected to contain `name` and `image` URL.
 */
const HeroSection = ({userInfo}) => {

    if (!userInfo) {
        return <div>Loading....</div>
    }

    const currentHour = new Date().getHours();
    let greeting;
    if (currentHour >= 0 && currentHour < 12) {
        greeting = "Good Morning!";
    } else if (currentHour >= 12 && currentHour < 18) {
        greeting = "Good Afternoon!";
    } else {
        greeting = "Good Evening!";
    }

    return (
        <>
            <div className="product-home-header-outer">
                <div className="user-name-image-container">
                    <div className="user-image-container" style={{backgroundImage: `url(${userInfo.image})`}}></div>
                    <div className="product-user-name-greeting-container">
                        <p>Hello,</p>
                        <p className="product-user-name-greeting-information-para">{userInfo.name}, {greeting}</p>
                    </div>
                </div>
                <div className="product-quick-actions-container">

                    {quickActionsButtons.map((action, index) => (
                        <QuickActionButton key={index} icon={< action.icon/>} onClick={action.onClick}>
                            {action.name}
                        </QuickActionButton>
                    ))}

                </div>
            </div>
        </>
    )
}

export default HeroSection;

