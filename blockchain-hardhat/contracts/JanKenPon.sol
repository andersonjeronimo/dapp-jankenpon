// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "./IJanKenPon.sol";
import "./JKPLibrary.sol";

contract JanKenPon is IJanKenPon{
    address payable private immutable owner;
    uint256 private bid = 0.01 ether;
    uint8 private commission = 10; //percent    

    mapping(JKPLibrary.Choice => mapping(JKPLibrary.Choice => JKPLibrary.Result)) challenge;

    JKPLibrary.Player[] public players;
    uint private constant ONE = 0;
    uint private constant TWO = 1;

    string public message = "";
    bool private isNewGame = true;
    mapping(address => uint) private scores;
    address[] private winners;

    function configGameLogig() private {
        challenge[JKPLibrary.Choice.Rock][JKPLibrary.Choice.Rock] = JKPLibrary.Result.Draw;
        challenge[JKPLibrary.Choice.Rock][JKPLibrary.Choice.Paper] = JKPLibrary.Result.Lost;
        challenge[JKPLibrary.Choice.Rock][JKPLibrary.Choice.Scissor] = JKPLibrary.Result.Win;

        challenge[JKPLibrary.Choice.Paper][JKPLibrary.Choice.Rock] = JKPLibrary.Result.Win;
        challenge[JKPLibrary.Choice.Paper][JKPLibrary.Choice.Paper] = JKPLibrary.Result.Draw;
        challenge[JKPLibrary.Choice.Paper][JKPLibrary.Choice.Scissor] = JKPLibrary.Result.Lost;

        challenge[JKPLibrary.Choice.Scissor][JKPLibrary.Choice.Rock] = JKPLibrary.Result.Lost;
        challenge[JKPLibrary.Choice.Scissor][JKPLibrary.Choice.Paper] = JKPLibrary.Result.Win;
        challenge[JKPLibrary.Choice.Scissor][JKPLibrary.Choice.Scissor] = JKPLibrary.Result.Draw;
    }

    constructor() {
        owner = payable(msg.sender);
        players.push(JKPLibrary.Player(address(0), JKPLibrary.Choice.None, JKPLibrary.Result.None));
        players.push(JKPLibrary.Player(address(0), JKPLibrary.Choice.None, JKPLibrary.Result.None));
        configGameLogig();
    }

    function updateWins(address winner) private {
        uint score = scores[winner];
        if (score == 0) {
            scores[winner] = 1;
            winners.push(winner);
        } else {
            scores[winner] += 1;
        }
    }

    function getBid() external view returns (uint256) {
        return bid;
    }

    function getCommission() external view returns (uint8) {
        return commission;
    }

    function setBid(uint256 newBid) external {
        require(msg.sender == owner, "You do not have permission");
        require(players[ONE].userAddress == address(0),
            "You cannot change bid with a game in progress");
        bid = newBid;
    }

    function setCommission(uint8 newCommission) external {
        require(msg.sender == owner, "You do not have permission.");
        require(players[ONE].userAddress == address(0),
            "You cannot change commission with a game in progress");
        commission = newCommission;
    }

    function getBalance() external view returns (uint) {
        require(msg.sender == owner, "This account do not have permission");
        return address(this).balance;
    }

    function choose(JKPLibrary.Choice _choice) external payable {
        require(msg.sender != owner, "The owner cannot play");
        require(players[ONE].userAddress == address(0) ||
                players[TWO].userAddress == address(0),
                "Play and reset for a new game"
        );
        if (players[ONE].userAddress == address(0)) {
            require(msg.value >= bid, "Invalid bid");
            players[ONE].userAddress = msg.sender;
            players[ONE].choice = _choice;
        } else {
            require(players[ONE].userAddress != address(0) &&
            msg.sender != players[ONE].userAddress,
            "Waiting player 2 choose");
            require(msg.value >= bid, "Invalid bid");
            players[TWO].userAddress = msg.sender;
            players[TWO].choice = _choice;
        }
    }

    function returnChoice(JKPLibrary.Player memory player) private pure returns (string memory) {
        if (player.choice == JKPLibrary.Choice.Rock) return "chose rock";
        if (player.choice == JKPLibrary.Choice.Paper) return "chose paper";
        if (player.choice == JKPLibrary.Choice.Scissor) return "chose scissor";
        return "chose nothing";
    }

    function returnResult(JKPLibrary.Player memory player) private pure returns (string memory) {
        if (player.result == JKPLibrary.Result.Win) return "wins";
        if (player.result == JKPLibrary.Result.Lost) return "loses";
        if (player.result == JKPLibrary.Result.Draw) return "draws";
        return "no contest";
    }

    function compareChoices() private {
        require(players[ONE].choice != JKPLibrary.Choice.None &&
                players[TWO].choice != JKPLibrary.Choice.None,
                "Players must choose Rock, Paper or Scissor"
        );
        players[ONE].result = challenge[players[ONE].choice][players[TWO].choice];
        players[TWO].result = challenge[players[TWO].choice][players[ONE].choice];

        message = string.concat("Player 1 ", returnResult(players[ONE])," and",
            " Player 2 ", returnResult(players[TWO]),
            " Player 1 ",returnChoice(players[ONE])," and",
            " Player 2 ",returnChoice(players[TWO])
        );
    }

    function pay() private {
        address contractAddress = address(this);
        owner.transfer((contractAddress.balance / 100) * commission);
        address payable winner;
        if (players[ONE].result == JKPLibrary.Result.Win) {
            winner = payable(players[ONE].userAddress);
            winner.transfer(contractAddress.balance);
        } else {
            if (players[TWO].result == JKPLibrary.Result.Win) {
                winner = payable(players[TWO].userAddress);
                winner.transfer(contractAddress.balance);
            }
        }
    }

    function rank() private {
        if (players[ONE].result == JKPLibrary.Result.Win) {
            updateWins(players[ONE].userAddress);
        } else {
            updateWins(players[TWO].userAddress);
        }
    }

    function reset() external {
        players[ONE].userAddress = address(0);
        players[ONE].choice = JKPLibrary.Choice.None;
        players[ONE].result = JKPLibrary.Result.None;

        players[TWO].userAddress = address(0);
        players[TWO].choice = JKPLibrary.Choice.None;
        players[TWO].result = JKPLibrary.Result.None;

        isNewGame = true;
        message = "";
    }

    function play() external {
        require(isNewGame, "You must reset for a new game");
        compareChoices();
        rank();
        pay();
        isNewGame = false;
    }

    function getLeaderboard() external view returns (address[] memory) {
        address[] memory leaderboard = new address[](3);
        leaderboard[0] = address(0);
        leaderboard[1] = address(0);
        leaderboard[2] = address(0);
        for (uint i = 0; i < winners.length; i++) {
            uint score = scores[winners[i]];
            for (uint j = 0; j < leaderboard.length - 1; j++) {
                if (leaderboard[j] == address(0)) {
                    leaderboard[j] = winners[i];
                } else {
                    if (score > scores[leaderboard[j]]) {
                        address swap = leaderboard[j];
                        leaderboard[j] = winners[i];
                        leaderboard[j + 1] = swap;
                    }
                }
            }
        }
        return leaderboard;
    }

    /* modifier restricted() {
        require(msg.sender == owner, "This account do not have permission");
        _;
    } */
}
