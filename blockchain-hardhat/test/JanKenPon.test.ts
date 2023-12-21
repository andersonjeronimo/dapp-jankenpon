import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("JanKenPon", function () {
  async function deployFixture() {
    const [owner, otherAccount] = await ethers.getSigners();

    const JanKenPon = await ethers.getContractFactory("JanKenPon");
    const contract = await JanKenPon.deploy();

    return { contract, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should test", async function () {
      const { contract, owner, otherAccount } = await loadFixture(deployFixture);
      expect(true).to.equal(true);
    });
  });
});
