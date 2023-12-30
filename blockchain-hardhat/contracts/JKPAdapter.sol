// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./IJanKenPon.sol";

contract JKPAdapter {
    address public immutable owner;
    IJanKenPon private janKenPon;

    constructor() {
        owner = msg.sender;
    }

    function getBid() external view upgraded returns (uint256) {
        return janKenPon.getBid();
    }

    function getCommission() external view upgraded returns (uint8) {
        return janKenPon.getCommission();
    }

    function setBid(uint256 newBid) external restricted upgraded {
        janKenPon.setBid(newBid);
    }

    function setCommission(uint8 newCommission) external restricted upgraded {
        janKenPon.setCommission(newCommission);
    }

    function getBalance() external view upgraded returns (uint) {
        return janKenPon.getBalance();
    }

    function choose(JKPLibrary.Choice _choice) external payable upgraded {
        require(msg.sender != owner, "The owner cannot play");
        janKenPon.choose{value: msg.value}(_choice);
    }

    function play() external upgraded {
        janKenPon.play();
    }

    function reset() external upgraded {
        janKenPon.reset();
    }

    function getLeaderboard() external view upgraded returns (address[] memory) {
        return janKenPon.getLeaderboard();
    }

    function upgrade(address newImplementation) external restricted {
        require(newImplementation != address(0), "Empty address is not permitted");        
        janKenPon = IJanKenPon(newImplementation);
    }

    function getImplementationAddress() external view returns (address) {
        return address(janKenPon);
    }

    modifier upgraded() {
        require(address(janKenPon) != address(0), "Must upgrade contract first");
        _;
    }

    modifier restricted() {
        require(msg.sender == owner, "You do not have permission");
        _;
    }
}