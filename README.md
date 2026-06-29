<div align="center">

# 🎨 NFTMarket GH

**A decentralized NFT minting and trading platform built for Ghanaian artists.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![React](https://img.shields.io/badge/React-18-61DAFB?logo=react&logoColor=white)](https://reactjs.org/)
[![Solidity](https://img.shields.io/badge/Solidity-0.8-363636?logo=solidity&logoColor=white)](https://soliditylang.org/)
[![Ethereum](https://img.shields.io/badge/Network-Rinkeby-3C3C3D?logo=ethereum&logoColor=white)](https://rinkeby.etherscan.io/)
[![IPFS](https://img.shields.io/badge/Storage-IPFS-65C2CB?logo=ipfs&logoColor=white)](https://ipfs.tech/)
[![Web3.js](https://img.shields.io/badge/Web3.js-1.x-F16822?logo=web3dotjs&logoColor=white)](https://web3js.readthedocs.io/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Made in Ghana](https://img.shields.io/badge/Made%20in-Ghana%20🇬🇭-006B3F)](https://github.com/KelvCodes/NFTMarketGH)

NFTMarket GH bridges the gap between African creativity and blockchain technology — giving local artists a transparent, trustless way to tokenize, showcase, and sell their work.

[Getting Started](#-getting-started) · [Features](#-features) · [Tech Stack](#-tech-stack) · [Contributing](#-contributing)

</div>

---

## ✨ Features

- 🖼️ **ERC-721 NFT Minting** — Mint unique, standards-compliant tokens from any artwork
- 📦 **IPFS Decentralized Storage** — Assets stored off-chain, permanently and censorship-resistant
- 📜 **Ownership History** — Full provenance tracking on the Ethereum Rinkeby testnet
- ⚛️ **React Frontend** — Clean, responsive UI for browsing, minting, and trading
- 🔗 **Web3 Integration** — Connect your wallet and interact with the blockchain seamlessly

---

## 🛠️ Tech Stack

| Layer | Technology | Badge |
|---|---|---|
| Smart Contracts | Solidity (ERC-721) | ![Solidity](https://img.shields.io/badge/Solidity-363636?logo=solidity&logoColor=white) |
| Blockchain | Ethereum — Rinkeby Testnet | ![Ethereum](https://img.shields.io/badge/Ethereum-3C3C3D?logo=ethereum&logoColor=white) |
| Frontend | React | ![React](https://img.shields.io/badge/React-61DAFB?logo=react&logoColor=black) |
| Storage | IPFS | ![IPFS](https://img.shields.io/badge/IPFS-65C2CB?logo=ipfs&logoColor=white) |
| Web3 Integration | Web3.js | ![Web3](https://img.shields.io/badge/Web3.js-F16822?logo=web3dotjs&logoColor=white) |
| Package Manager | npm | ![npm](https://img.shields.io/badge/npm-CB3837?logo=npm&logoColor=white) |

---

## ⚡ Getting Started

### Prerequisites

![Node](https://img.shields.io/badge/Node.js-≥16-339933?logo=nodedotjs&logoColor=white)
![MetaMask](https://img.shields.io/badge/MetaMask-Required-E2761B?logo=metamask&logoColor=white)

- **Node.js** ≥ 16
- **Truffle** — `npm install -g truffle`
- **MetaMask** browser extension
- **Rinkeby testnet ETH** — grab some from the [Chainlink faucet](https://faucets.chain.link/rinkeby)

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/KelvCodes/NFTMarketGH.git
cd NFTMarketGH

# 2. Install dependencies
npm install

# 3. Deploy smart contracts to Rinkeby
truffle migrate --network rinkeby

# 4. Start the app
npm start
```

Open [http://localhost:3000](http://localhost:3000) and connect your MetaMask wallet to mint your first NFT. 🎉

---

## 🔄 How It Works

```
Connect Wallet  →  Upload Artwork  →  Mint NFT  →  List / Trade  →  Track Provenance
     🦊                 🖼️               🪙            💸                  📜
```

1. 🦊 **Connect** your MetaMask wallet to the Rinkeby testnet
2. 🖼️ **Upload** your artwork — it's pinned to IPFS automatically
3. 🪙 **Mint** an ERC-721 token tied to your piece
4. 💸 **Trade** — list it for sale or transfer ownership directly
5. 📜 **Track** the full ownership history on-chain, forever

---

## 📁 Project Structure

```
NFTMarketGH/
├── 📂 contracts/          # Solidity smart contracts
├── 📂 migrations/         # Truffle deployment scripts
├── 📂 src/
│   ├── 📂 components/     # React UI components
│   ├── 📂 utils/          # Web3 helpers
│   └── 📄 App.js
├── 📂 test/               # Contract tests
└── 📄 truffle-config.js
```

---

## 🤝 Contributing

[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![GitHub issues](https://img.shields.io/github/issues/KelvCodes/NFTMarketGH)](https://github.com/KelvCodes/NFTMarketGH/issues)
[![GitHub forks](https://img.shields.io/github/forks/KelvCodes/NFTMarketGH)](https://github.com/KelvCodes/NFTMarketGH/network)
[![GitHub stars](https://img.shields.io/github/stars/KelvCodes/NFTMarketGH)](https://github.com/KelvCodes/NFTMarketGH/stargazers)

Contributions are welcome! To get started:

1. 🍴 Fork the repository
2. 🌿 Create a feature branch: `git checkout -b feature/your-feature`
3. 💾 Commit your changes: `git commit -m "Add your feature"`
4. 🚀 Push and open a Pull Request

Please open an issue first for major changes.

---

## 📄 License

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

[MIT](LICENSE) — free to use, modify, and distribute.

---

<div align="center">

*Built with 🖤 to empower Ghanaian artists on the blockchain.*

[![GitHub](https://img.shields.io/badge/GitHub-KelvCodes-181717?logo=github&logoColor=white)](https://github.com/KelvCodes)

</div>
