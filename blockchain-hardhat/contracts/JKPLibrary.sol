// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library JKPLibrary {
    enum Choice {
        None,
        Rock,
        Paper,
        Scissor
    }
    enum Result {
        None,
        Draw,
        Win,
        Lost
    }
    struct Player {
        address userAddress;
        Choice choice;
        Result result;
    }       
}