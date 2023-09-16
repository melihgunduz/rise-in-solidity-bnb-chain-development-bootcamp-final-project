import { ethers } from "hardhat";

async function main() {

  const smartTransfer = await ethers.deployContract("SmartTransfer"); //defining our contract

  await smartTransfer.waitForDeployment(); // deploying our contract on network
  console.log(await smartTransfer.getAddress()) // writing contract address to the console
  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
