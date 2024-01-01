import { ethers } from "hardhat";

async function main() {
  const implementation = await ethers.deployContract("JanKenPon");
  await implementation.waitForDeployment();
  const implementationAddress = await implementation.getAddress();
  console.log(`JanKenPonn implementation deployed at ${implementationAddress}`);
  
  /* const adapter = await ethers.deployContract("JKPAdapter");
  await adapter.waitForDeployment();
  const adapterAddress = await implementation.getAddress();
  console.log(`JanKenPonn implementation deployed at ${adapterAddress}`);

  await adapter.upgrade(implementationAddress);
  console.log(`Adapter was upgraded with implementation address: ${implementationAddress}`); */
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
