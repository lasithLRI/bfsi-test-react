import {Route, Routes} from "react-router-dom";
import HomePage from "./home_page/HomePage.jsx";
import {HeaderIconButton} from "./components/AppCommonComponents.jsx";
import "./AccountsCentralApplication.css";

const AccountsCentralApplication = ()=>{
    return (
        <>
            <div className="header-outer">
                <p>Accounts Central</p>
                <HeaderIconButton/>
            </div>

            <div className="content-outer">
                <Routes>
                    <Route path="/home" element={<HomePage/>}/>
                </Routes>
            </div>

        </>
    )
}

export default AccountsCentralApplication;