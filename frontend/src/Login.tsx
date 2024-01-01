import React from 'react';
import logo from './logo.svg';
import './App.css';
import { useState, useEffect } from 'react';
import { doLogin } from './Web3Service';

function Login() {
  const [message, setMessage] = useState("Waiting for authentication");
  function onBtnClick() {
    setMessage("Connecting to MetaMask wallet...");
    doLogin().then(
      result => {
        alert(JSON.stringify(result));
        setMessage(`Wallet: ${result.account}`)
      }).catch(err => setMessage(err.message));
  }
  useEffect(()=>{
    if (localStorage.getItem("account") !== null) {
      setMessage(`Already authenticated with wallet: ${localStorage.getItem("account")}`);
    }
  }, []);


  return (
    <div className="Login">
      <header className="Login-header">


        <div className="text-center">
          <img src={logo} className="App-logo" alt="logo" />
          <button type="button" className="btn btn-primary" onClick={onBtnClick}>
            Login MetaMask</button>
        </div>
        <p className='lead'>
          {message}
        </p>


      </header>
    </div>
  );
}

export default Login;
