// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "./JKPLibrary.sol";

interface IJanKenPon {    
    function getBid() external view returns (uint256);
    function getCommission() external view returns (uint8);
    function setBid(uint256 newBid) external;
    function setCommission(uint8 newCommission) external;
    function getBalance() external view returns (uint);
    function choose(JKPLibrary.Choice _choice) external payable;
    function play() external;
    function reset() external;
    function getLeaderboard() external view returns (address[] memory);    
}
