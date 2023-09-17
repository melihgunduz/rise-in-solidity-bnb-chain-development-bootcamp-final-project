# Hardhat Smart Contract Project for Rise In

This project is a final case project for Rise In Solidity & BNB Chain Development Bootcamp.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Testing](#testing)
- [Contributing](#contributing)
- [License](#license)

## Overview

The **Smart Transfer DApp** provides to the users can be transfer their balances to the other users, lock and unlock their balances, get reward from contract. You can analyze contract on BSC Testnet: https://testnet.bscscan.com/address/0xba8D43495B3e7c7FD7FBb131336d2d1531b5F1ab#code

## Features

- Buy token from contract.
- Transfer the tokens to the other users.
- Lock and unlock your tokens.
- Get your rewards which calculated by time when you unlock your locked balances.
- Sell tokens to the contract and get paid.
- Ethereum Wallet Integration: Connect your Ethereum wallet (e.g., MetaMask) to participate directly.

## Getting Started

Follow these steps to set up the project locally and start participating in web3 auctions.

### Prerequisites

1. Node.js: Ensure Node.js is installed. Download it from [nodejs.org](https://nodejs.org/).

### Installation

1. Clone the repository:

```bash
  git clone https://github.com/melihgunduz/rise-in-solidity-bnb-chain-development-bootcamp-final-project.git
```

2. Navigate to the project directory:

```bash
  cd rise-in-solidity-bnb-chain-development-bootcamp-final-project
```

3. Install required npm packages:

```bash
 npm install
```
4. Create secrets.json at root of the project:
```json
    
  {
    "MNEMONIC": "your 12-word seed phrase",
    "BSCAPIKEY": "bscscanApiKey"
  }

```
## Testing

Smart contract tests are located in the `test` folder. These tests ensure the correct functioning of the smart contract. To run the tests, follow these steps:

1. Open a terminal in the project directory.
2. Run the following command to execute the tests:

```bash
npx hardhat test ./test/SmartTransfer.ts
```
or
```bash
npx hardhat test ./test/YourTestScript
```

This command will initiate the smart contract tests and display the results in the terminal.

![]
![image](https://github.com/melihgunduz/rise-in-solidity-bnb-chain-development-bootcamp-final-project/blob/main/assets/smart-transfer-test-image.png)

## Contributing

Contributions to this project are welcome! To contribute:

1. Fork the repository.
2. Create a new branch for your feature/bug fix.
3. Make changes and test thoroughly.
4. Commit with clear and concise messages.
5. Push changes to your fork.
6. Submit a pull request describing your changes.


## License

This project is licensed under the [MIT License](LICENSE).



