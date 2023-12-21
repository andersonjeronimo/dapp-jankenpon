// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

contract JanKenPon {
    address payable private immutable owner;

    enum Choice { None, Rock, Paper, Scissor }
    enum Status { None, Draw, Won, Lost }
    
    struct Player {
        address userAddress;
        Choice choice;
        Status status;        
    }   
    
    Player one = Player(address(0), Choice.None , Status.None);
    Player two = Player(address(0), Choice.None, Status.None);
        
    string public message = "";

    address[] public winners;

    constructor(){
        owner = payable(msg.sender);
    }

    function exists(address winner) private view returns (bool){
        for (uint i = 0; i < winners.length; i++) {
            if (winners[i] == winner) return true;            
        }
        return  false;
    }

    function balance() public ownerOnly view returns (uint){
        //require(msg.sender == owner, "This account don't have permission.");
        return address(this).balance;
    }    

    function choose(Choice _choice) public payable {
        require(one.userAddress == address(0) || two.userAddress == address(0), 
        "Play and reset for a new game");
        
        if (one.userAddress == address(0)) {
            require(msg.value >= 0.001 ether, "Invalid bid. Must be >= 0.001 ETH (1.000.000 Gwei)");
            one.userAddress = msg.sender;
            one.choice = _choice;            
        } else {
            require(one.userAddress != address(0) && msg.sender != one.userAddress, "Waiting player 2 choose.");
            require(msg.value >= 0.001 ether, "Invalid bid. Must be >= 0.001 ETH (1.000.000 Gwei)");
            two.userAddress = msg.sender;
            two.choice = _choice;
        }        
    } 

    function returnChoice(Player memory player) private pure returns (string memory) {        
        if (player.choice == Choice.Rock) return "Rock";
        if (player.choice == Choice.Paper) return "Paper";
        if (player.choice == Choice.Scissor) return "Scissor";
        return "None";
    }

    function play() private {
       require(one.choice != Choice.None && two.choice != Choice.None, "Players must choose Rock, Paper or Scissor");   
       uint8 choiceP1 = uint8(one.choice);
       uint8 choiceP2 = uint8(two.choice);
       if (choiceP1 == choiceP2) {
        one.status = Status.Draw;
        two.status = Status.Draw;
        message = string.concat("DRAW: ", "Player 1 (", 
        returnChoice(one), ") and Player 2 (", returnChoice(two), ")");
        
       } else if(choiceP1 > choiceP2 ){        
        if (choiceP1 - choiceP2 == 1) {
            one.status = Status.Won;
            two.status = Status.Lost;
            message = string.concat("Player 1 WON: ", "Player 1 (", 
            returnChoice(one), ") and Player 2 (", returnChoice(two), ")");
        } else {
            one.status = Status.Lost;
            two.status = Status.Won;
            message = string.concat("Player 1 LOST: ", "Player 1 (", 
            returnChoice(one), ") and Player 2 (", returnChoice(two), ")");
        }        
       } else {        
        if (choiceP2 - choiceP1 == 1) {
            two.status = Status.Won;
            one.status = Status.Lost;
            message = string.concat("Player 2 WON: ", "Player 1 (", 
            returnChoice(one), ") and Player 2 (", returnChoice(two),")");            
        } else {
            two.status = Status.Lost;
            one.status = Status.Won;
            message = string.concat("Player 2 LOST: ", "Player 1 (", 
            returnChoice(one), ") and Player 2 (", returnChoice(two), ")");
        }
       }       
    }

    function pay() private  {
        //require(msg.sender == owner, "This account don't have permission.");
        address contractAddress = address(this);
        owner.transfer((contractAddress.balance / 100) * 10);
        address payable winner;
        if (one.status == Status.Won) {
            winner = payable(one.userAddress);
            winner.transfer(contractAddress.balance);
        } 
        else {
            if(two.status == Status.Won){
                winner = payable(two.userAddress);
                winner.transfer(contractAddress.balance);
            }
        }
    }

    function rank() private {
        //require(msg.sender == owner, "This account don't have permission.");
        if (one.status == Status.Won) {
            if (!exists(one.userAddress)) {
                winners.push(one.userAddress);                
            }
        } else {
            if (!exists(two.userAddress)) {
                winners.push(two.userAddress);                
            }
        }
    }

    function run() public {
        play();
        rank();
        pay();
    }

    function reset() public {
        one.userAddress = address(0);
        one.choice = Choice.None;
        one.status = Status.None;

        two.userAddress = address(0);
        two.choice = Choice.None;
        two.status = Status.None;

        message = "";        
    }

    modifier ownerOnly(){
        require(msg.sender == owner, "This account don't have permission.");
        _;
    }
}