import { expect } from "chai";
import { ethers } from "hardhat";

describe("SmartTransfer", function () {

  // async function deploySpacebearAndMintTokenFixture() {
  //   // deploy a lock contract where funds can be withdrawn
  //   // one year in the future
  //   const SmartTransfer = await ethers.getContractFactory("SmartTransfer");
  //   const smartTransferInstance = await SmartTransfer.deploy();

  //   const [owner, otherAccount] = await ethers.getSigners();

  //   return { smartTransferInstance, owner, otherAccount };
  // }

  it("should pay for token to the contract", async function () {
    const SmartTransfer = await ethers.getContractFactory("SmartTransfer");
    const smartTransferInstance = await SmartTransfer.deploy();

    const [owner] = await ethers.getSigners();
    await smartTransferInstance.buyToken({value: ethers.parseEther("0.001")});

    expect(await smartTransferInstance.checkBalanceOfUser(owner)).to.greaterThanOrEqual(ethers.parseEther("0.001"));
  });

  it("should sell tokens to the contract", async function() {
    const SmartTransfer = await ethers.getContractFactory("SmartTransfer");
    const smartTransferInstance = await SmartTransfer.deploy();
    const [owner] = await ethers.getSigners();
    await smartTransferInstance.buyToken({value: ethers.parseEther("0.001")});
    await smartTransferInstance.sellToken(ethers.parseEther("0.001"));
    
    expect(await smartTransferInstance.checkBalanceOfUser(owner.address)).to.lessThanOrEqual(ethers.parseEther("0"));
  });
 
  it("should transfer tokens between accounts", async function() {
    const SmartTransfer = await ethers.getContractFactory("SmartTransfer");
    const smartTransferInstance = await SmartTransfer.deploy();
    const [owner, acc1] = await ethers.getSigners();
    await smartTransferInstance.buyToken({value: ethers.parseEther("0.001")});
    await smartTransferInstance.transferToken(owner.address, acc1.address, ethers.parseEther("0.001"));
    
    expect(await smartTransferInstance.checkBalanceOfUser(acc1.address)).to.greaterThanOrEqual(ethers.parseEther("0.001"));
  });
 
  it("should lock tokens from user", async function() {
    const SmartTransfer = await ethers.getContractFactory("SmartTransfer");
    const smartTransferInstance = await SmartTransfer.deploy();
    await smartTransferInstance.buyToken({value: ethers.parseEther("0.001")});
    await smartTransferInstance.lockTokens(ethers.parseEther("0.001"));

    expect(await smartTransferInstance.getLockedAmount()).to.greaterThan(ethers.parseEther("0"));
  });
 
  it("should unlock tokens of user", async function() {
    const SmartTransfer = await ethers.getContractFactory("SmartTransfer");
    const smartTransferInstance = await SmartTransfer.deploy();
    await smartTransferInstance.buyToken({value: ethers.parseEther("0.001")});
    await smartTransferInstance.lockTokens(ethers.parseEther("0.001"));
    await smartTransferInstance.unlockAllAvailableTokens();

    await expect(smartTransferInstance.getLockedAmount()).to.be.revertedWith('User do not have any locked amount');
  });

});
