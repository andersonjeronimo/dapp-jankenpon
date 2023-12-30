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
        const jankenpon = await JanKenPon.deploy();

        const JKPAdapter = await ethers.getContractFactory("JKPAdapter");
        const jkpadapter = await JKPAdapter.deploy();

        return { jankenpon, jkpadapter, owner, otherAccount1, otherAccount2 };
    }

    describe("Contract adapter tests", function () {

        it("Should get implementation address", async function () {
            const { jankenpon, jkpadapter, owner, otherAccount1, otherAccount2 } = await loadFixture(deployFixture);

            const address = await jankenpon.getAddress();

            await jkpadapter.upgrade(jankenpon);
            const implementationAddress = await jkpadapter.getImplementationAddress();

            expect(address).to.equal(implementationAddress);
        });

        it("Should NOT get bid (upgrade)", async function () {
            const { jankenpon, jkpadapter, owner, otherAccount1, otherAccount2 } = await loadFixture(deployFixture);            
            await expect(jkpadapter.getBid())
                .to.be.revertedWith("Must upgrade contract first");
        });

        it("Should NOT upgrade (address zero)", async function () {
            const { jankenpon, jkpadapter, owner, otherAccount1, otherAccount2 } = await loadFixture(deployFixture);

            await expect(jkpadapter.upgrade(ethers.ZeroAddress))
                .to.be.revertedWith("Empty address is not permitted");
        });

        it("Should NOT upgrade (permission)", async function () {
            const { jankenpon, jkpadapter, owner, otherAccount1, otherAccount2 } = await loadFixture(deployFixture);

            const instance = jkpadapter.connect(otherAccount1);

            await expect(instance.upgrade(jankenpon))
                .to.be.revertedWith("You do not have permission");
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
