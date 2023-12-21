import { ethers } from "hardhat";

async function main() {
  const contract = await ethers.deployContract("JanKenPon");
  await contract.waitForDeployment();
  const address = await contract.getAddress();
  console.log(`JanKenPonn contract deployed at ${address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
