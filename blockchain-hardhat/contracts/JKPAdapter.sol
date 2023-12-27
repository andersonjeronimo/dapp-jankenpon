// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./IJanKenPon.sol";

contract JKPAdapter {
    address public immutable owner;
    IJanKenPon private janKenPon;
    constructor() {
        owner = msg.sender;
    }

    function upgrade(address newImplementation) external {
        require(msg.sender == owner, "You do not have permission");
        require(newImplementation != address(0), "Empty contract address");
        janKenPon = IJanKenPon(newImplementation);
    }

    function getAddress() external view upgraded returns (address) {
        return address(janKenPon);
    }    

    modifier upgraded {
        require(address(janKenPon) != address(0), "Must upgrade contract first");
        _;
    }
}