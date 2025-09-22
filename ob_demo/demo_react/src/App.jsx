import './App.css'
import {Route, Routes} from "react-router-dom";

import AccountsCentralApplication from "./tpp_application/AccountsCentralApplication.jsx";

function App() {


  return (
    <>
      <Routes>
          <Route path="/accounts-central/*" element={<AccountsCentralApplication/>} />
      </Routes>

    </>
  )
}

export default App
