import { ethers } from "hardhat";

async function main() {
  const implementation = await ethers.deployContract("JanKenPon");
  await implementation.waitForDeployment();
  const implementationAddress = await implementation.getAddress();
  console.log(`JanKenPonn implementation deployed at ${implementationAddress}`);

  const adapter = await ethers.deployContract("JKPAdapter");
  await adapter.waitForDeployment();
  const adapterAddress = await adapter.getAddress();
  console.log(`JanKenPonn adapter deployed at ${adapterAddress}`);

  await adapter.upgrade(implementationAddress);
  console.log(`Adapter was upgraded with implementation address: ${implementationAddress}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

//const [owner, p1, p2] = await ethers.getSigners();
//const contract = await ethers.getContractAt("JKPAdapter", "0x9fe46736679d2d9a65f0992f2272de9f3c7fa6e0");

/**
 JanKenPonn implementation deployed at 0x829B32b0dB598CD9A703eBc57C79F9e0C81e1E5B
JanKenPonn adapter deployed at 0x82174665126f7B690df0d86e32bcd682ea4843bC
Adapter was upgraded with implementation address: 0x829B32b0dB598CD9A703eBc57C79F9e0C81e1E5B
 */