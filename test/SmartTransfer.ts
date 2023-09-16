import { expect } from "chai";
import { ethers } from "hardhat";

describe("SmartTransfer", function () {

  it("should pay for token to the contract", async function () {
    const SmartTransfer = await ethers.getContractFactory("SmartTransfer"); // defining smart contract
    const smartTransferInstance = await SmartTransfer.deploy(); // deploying smart contract

    const [owner] = await ethers.getSigners(); // get account(s) from network
    await smartTransferInstance.buyToken({value: ethers.parseEther("0.001")}); // trigger buy token function

    // defining what we expect
    expect(await smartTransferInstance.checkBalanceOfUser(owner)).to.greaterThanOrEqual(ethers.parseEther("0.001")); 
    //we expecting balance of user greater than 0.001 ether
  });

  it("should sell tokens to the contract", async function() {
    const SmartTransfer = await ethers.getContractFactory("SmartTransfer"); // defining smart contract
    const smartTransferInstance = await SmartTransfer.deploy(); // deploying smart contract

    const [owner] = await ethers.getSigners(); // get account(s) from network
    await smartTransferInstance.buyToken({value: ethers.parseEther("0.001")}); // trigger buy token function
    await smartTransferInstance.sellToken(ethers.parseEther("0.001")); // trigger sell token function
    
    // defining what we expect
    expect(await smartTransferInstance.checkBalanceOfUser(owner.address)).to.equal(ethers.parseEther("0"));
    //we expecting balance of user equal 0 ether
  });
 
  it("should transfer tokens between accounts", async function() {
    const SmartTransfer = await ethers.getContractFactory("SmartTransfer"); // defining smart contract
    const smartTransferInstance = await SmartTransfer.deploy(); // deploying smart contract
    const [owner, acc1] = await ethers.getSigners(); // get account(s) from network
    await smartTransferInstance.buyToken({value: ethers.parseEther("0.001")}); // trigger buy token function
    await smartTransferInstance.transferToken(owner.address, acc1.address, ethers.parseEther("0.001"));//trigger transfer token function
    
    // defining what we expect
    expect(await smartTransferInstance.checkBalanceOfUser(acc1.address)).to.greaterThanOrEqual(ethers.parseEther("0.001"));
    //we expecting balance of acc1 user greater than or equal 0.001 ether
  });
 
  it("should lock tokens from user", async function() {
    const SmartTransfer = await ethers.getContractFactory("SmartTransfer"); // defining smart contract
    const smartTransferInstance = await SmartTransfer.deploy(); // deploying smart contract
    await smartTransferInstance.buyToken({value: ethers.parseEther("0.001")});// trigger buy token function
    await smartTransferInstance.lockTokens(ethers.parseEther("0.001")); // trigger lock tokens function

    // defining what we expect
    expect(await smartTransferInstance.getLockedAmount()).to.greaterThan(ethers.parseEther("0"));
    //we expecting locked balance of user greater than 0.001 ether
  });
 
  it("should unlock tokens of user", async function() {
    const SmartTransfer = await ethers.getContractFactory("SmartTransfer"); // defining smart contract
    const smartTransferInstance = await SmartTransfer.deploy(); // deploying smart contract
    await smartTransferInstance.buyToken({value: ethers.parseEther("0.001")});// trigger buy token function
    await smartTransferInstance.lockTokens(ethers.parseEther("0.001")); // trigger lock tokens function
    await smartTransferInstance.unlockAllAvailableTokens(); // trigger unlock the locked tokens

    // defining what we expect
    await expect(smartTransferInstance.getLockedAmount()).to.be.revertedWith('User do not have any locked amount'); // take care using await if you waiting revert
    // we expecting locked balance of user equals 0 ether but in our smart contract we are checking the locked balance
    // and reverting if there is no locked balance. that's why we expecting a revert with warning
  });

});
