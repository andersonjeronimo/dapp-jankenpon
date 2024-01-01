import Web3 from "web3";
import ABI from "./abi.json";

type loginResult = {
    account: string,
    isAdmin: boolean
}

export async function doLogin(): Promise<loginResult> {
    if (!window.ethereum) throw new Error("");

    const web3 = new Web3(window.ethereum);
    const accounts = await web3.eth.requestAccounts();
    if (!accounts || !accounts.length) {
        throw new Error("Wallet not found or not allowed");
    }
    const contract = new web3.eth.Contract(ABI, process.env.REACT_APP_CONTRACT_ADDRESS, { from: accounts[0] });
    const ownerAddress: string = await contract.methods.owner().call();

    localStorage.setItem("account", accounts[0]);
    localStorage.setItem("isAdmin", `${accounts[0] === ownerAddress}`);

    return {
        account: accounts[0],
        isAdmin: accounts[0] === ownerAddress
    }
}