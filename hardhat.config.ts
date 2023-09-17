import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
const {MNEMONIC, BSCAPIKEY} = require('./secrets.json');

const config: HardhatUserConfig = {
  solidity: "0.8.19",
  defaultNetwork: "hardhat",
  networks: {
    mocha: {
      url: "127.0.0.1:8545",
      timeout: 100000000
    },
    hardhat: {
    },
    testnet: {
      url: "https://data-seed-prebsc-1-s1.bnbchain.org:8545",
      chainId: 97,
      gasPrice: 20000000000,
      accounts: {mnemonic: MNEMONIC},
    },
  },
  etherscan: {
    apiKey: BSCAPIKEY
  }
};

export default config;
