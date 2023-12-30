import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("JanKenPon", function () {
  enum Choice {
    None,
    Rock,
    Paper,
    Scissor
  }

  const DEFAULT_BID = ethers.parseEther("0.01");

  async function deployFixture() {
    const [owner, otherAccount1, otherAccount2] = await ethers.getSigners();

    const JanKenPon = await ethers.getContractFactory("JanKenPon");
    const contract = await JanKenPon.deploy();

    return { contract, owner, otherAccount1, otherAccount2 };
  }

  describe("Contract tests", function () {   

    it("Should get the leaderboard", async function () {
      const { contract, owner, otherAccount1, otherAccount2 } = await loadFixture(deployFixture);

      const instance1 = contract.connect(otherAccount1);
      await instance1.choose(Choice.Rock, { value: DEFAULT_BID });

      const instance2 = contract.connect(otherAccount2);
      await instance2.choose(Choice.Scissor, { value: DEFAULT_BID });
      
      await instance2.play();

      const leaderboard = await contract.getLeaderboard();

      expect(leaderboard[0]).to.equal(otherAccount1.address);
    });    

    //TO_DO tests
    //should set bid
    //should NOT set bid (owner)    
    //should set commission    
    
    //expect(...).to.be.revertedWith("Waiting player 2 choose")
    //expect(...).to.be.revertedWith("Players must choose Rock, Paper or Scissor")
    //expect(...).to.be.revertedWith("You cannot change commission with a game in progress")
    //expect(...).to.be.revertedWith("You cannot change bid with a game in progress")
    //expect(...).to.be.revertedWith("The owner cannot play!")
    //expect(...).to.be.revertedWith("Invalid bid")

  });
});
