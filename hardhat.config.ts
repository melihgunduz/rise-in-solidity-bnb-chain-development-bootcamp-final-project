import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
const {MNEMONIC} = require('./secrets.json');

const config: HardhatUserConfig = {
  solidity: "0.8.19",
  networks: {
    hardhat: {
    },
    testnet: {
      url: "https://data-seed-prebsc-1-s1.bnbchain.org:8545",
      chainId: 97,
      gasPrice: 20000000000,
      accounts: {mnemonic: MNEMONIC}
    },
  }
};

export default config;
