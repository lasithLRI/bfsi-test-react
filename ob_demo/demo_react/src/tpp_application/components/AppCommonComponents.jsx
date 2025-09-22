import "./AppCommonComponents.css"
import {LoginIcon} from "../../svg_module/SvgModule.jsx";

export const HeaderIconButton = () => {


    return (
        <>
            <div className="header-icon-button-outer">
                <button className="icon-button-content">
                    <LoginIcon/>
                </button>
            </div>
        </>
    );
}