# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a Hardhat Ignition module that deploys that contract.

🌐Live
-  [Live Website](https://blockchain-crowd-funding-app-nine.vercel.app/)

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/Lock.js
```
🧱 Blockchain Crowdfunding Smart Contract DAPP

 📌 Project Overview

This project is a decentralized crowdfunding smart contract developed by **Mayureshwar Reddy**. The contract allows verified project creators to raise funds from contributors on the Ethereum blockchain, with support for early withdrawals, project status tracking, and platform commission.

✅ 15 Features have been implemented and tested.

---

🔧 Technologies Used

- **Solidity (v0.8.3)** – Smart contract language
- **Remix IDE** – Development & deployment
- **Hardhat** – Local testing (Task 5)
- **OpenZeppelin** – Reentrancy protection
- **MetaMask + Sepolia Testnet** – Ethereum wallet + testing

---

 📄 Smart Contract

Contract Name: "CrowdTank.sol"
Contains all logic for:

- Project creation, funding, and withdrawals
- Admin controls and access restrictions
- Overfunding logic and refund handling
- Tracking success/failure of projects
- System-wide 5% platform commission

---

✅ Features Implemented (1–15)

| Task No. | Description |
|----------|-------------|
| 1 | Return remaining time for project deadline |
| 2 | Track total raised funding |
| 3 | Events for user/admin withdrawals |
| 4 | Show remaining amount needed for project |
| 5 | Write scripts for withdraw functions |
| 6 | Extend deadline by creator |
| 7 | Change funding goal by creator |
| 8 | Prevent overfunding and refund extra ETH |
| 9 | Return funding percentage |
| 10 | Track total projects created |
| 11 | Early/partial user withdrawals before deadline |
| 12 | Admin access to add/remove creators |
| 13 | Track highest contributor per project |
| 14 | Track successful vs failed projects |
| 15 | Implement 5% commission and admin withdrawal |


----

## ⚙️ How to Run the Project

### Prerequisites:
- Node.js installed
- Alchemy (or Infura) account
- MetaMask wallet (with testnet ETH)

### Steps:

1. Clone the repo:
- git clone https://github.com/Mayuresh306/Blockchain-CrowdFunding-App.git
- cd CROWD_TANK

2. Install dependencies:
- npm install

3. Create a .env file in the root directory:
- cp .env.example .env
- Fill in your own credentials inside .env:
- PRIVATE_KEY=your_private_key_here
- ALCHEMY_API_KEY=your_alchemy_api_key_here

4. Run tests or scripts:
- npx hardhat run scripts/deploy.js --network sepolia

---

🛡 Bonus: Use dotenv in your scripts securely
- Your Hardhat config file should use:

- require("dotenv").config();

module.exports = {
  networks: {
    sepolia: {
        url: `https://eth-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`,
      accounts: [process.env.PRIVATE_KEY]
    }
  },
  solidity: "0.8.3"
};

---


🧪 How to Use

 1. Deploy Contract
- Use *Remix* or *Hardhat* to deploy "CrowdTank.sol"
- Use "Injected Web3" with MetaMask for testnet

 2. Add Authorized Creators (Admin only)
- Add_Creators(address)

3. Create Project
- createProject("Title", "Desc", fundingGoal, durationInSeconds, uniqueID)

4. Fund a Project
- fundProject(projectID)
- Send ETH — only 95% goes to the project, 5% is collected as commission.

5. Withdraw Funds
- creatorWithdraw(projectID) → By creator after successful funding
- userWithdraw(projectID) → By contributor if funding fails
- userEarlyWithdraw(projectID, amount) → Early partial withdrawal

6. Project Status Tracking
- UpdateProjectStatus()
- GetProjectStatus()
- ProjectStatistics()

7. Admin Withdraws Commission
- withdrawCommission()

---

🔐 Roles & Access
- Admin: Contract deployer with exclusive rights to add/remove creators & withdraw commission
- Authorized Creators: Only these addresses can create new projects

🙋‍♂️ Developer
- Mayureshwar Reddy
- 📧 mayureshreddy2006@gmail.com
- 📍 Kalyan, Maharashtra
- 🔗 https://www.linkedin.com/in/mayureshwar-reddy-37a4a2342?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=android_app

📜 License
MIT License © 2025 Mayureshwar Reddy
