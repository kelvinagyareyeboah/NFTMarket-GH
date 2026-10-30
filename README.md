<div align="center">

<img src="https://raw.githubusercontent.com/KelvCodes/NFTMarketGH/main/docs/banner.png" alt="NFTMarket GH" width="100%" />

# NFTMarket GH

**Mint, showcase, and trade African art on the blockchain.**

A decentralized NFT marketplace built for Ghanaian artists.

<br />

[![License](https://img.shields.io/badge/license-MIT-2ea44f?style=for-the-badge)](LICENSE)
[![Solidity](https://img.shields.io/badge/Solidity-0.8-363636?style=for-the-badge&logo=solidity&logoColor=white)](https://soliditylang.org/)
[![React](https://img.shields.io/badge/React-18-61DAFB?style=for-the-badge&logo=react&logoColor=black)](https://reactjs.org/)
[![IPFS](https://img.shields.io/badge/IPFS-Storage-65C2CB?style=for-the-badge&logo=ipfs&logoColor=black)](https://ipfs.tech/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen?style=for-the-badge)](CONTRIBUTING.md)

[Features](#features) •
[Quick Start](#quick-start) •
[How It Works](#how-it-works) •
[Architecture](#architecture) •
[Roadmap](#roadmap) •
[Contributing](#contributing)

</div>

---

## Overview

NFTMarket GH gives Ghanaian artists a transparent, trustless way to tokenize and sell their work. Artists keep ownership, every sale is recorded on-chain, and artwork lives on IPFS rather than a single company's server.

## Features

| | Feature | Description |
|---|---|---|
| 🖼️ | **ERC-721 Minting** | Turn any artwork into a unique, standards-compliant token |
| 📦 | **Decentralized Storage** | Assets are pinned to IPFS, so they're permanent and censorship-resistant |
| 📜 | **Provenance Tracking** | Full ownership history is verifiable on-chain |
| 🔗 | **Wallet Integration** | Connect with MetaMask and interact through Web3.js |
| ⚛️ | **Responsive UI** | Browse, mint, and trade from a clean React frontend |

## Quick Start

### Prerequisites

![Node.js](https://img.shields.io/badge/Node.js-%E2%89%A516-339933?style=flat-square&logo=nodedotjs&logoColor=white)
![Truffle](https://img.shields.io/badge/Truffle-5.x-5E464D?style=flat-square&logo=truffle&logoColor=white)
![MetaMask](https://img.shields.io/badge/MetaMask-required-E2761B?style=flat-square&logo=metamask&logoColor=white)

- [Node.js](https://nodejs.org/) 16 or later
- [Truffle](https://trufflesuite.com/): `npm install -g truffle`
- [MetaMask](https://metamask.io/) browser extension
- Testnet ETH from a [Sepolia faucet](https://sepoliafaucet.com/)

> [!WARNING]
> The Rinkeby testnet was shut down in 2022. Point `truffle-config.js` at **Sepolia** (or another live testnet) before deploying.

### Install and run

```bash
# Clone
git clone https://github.com/KelvCodes/NFTMarketGH.git
cd NFTMarketGH

# Install dependencies
npm install

# Deploy contracts
truffle migrate --network sepolia

# Start the app
npm start
```

Open **http://localhost:3000**, connect your wallet, and mint your first NFT.

## How It Works

```mermaid
flowchart LR
    A[Connect Wallet] --> B[Upload Artwork]
    B --> C[Pin to IPFS]
    C --> D[Mint ERC-721]
    D --> E[List or Transfer]
    E --> F[Track Provenance]
```

1. **Connect** your MetaMask wallet to the testnet.
2. **Upload** your artwork. It's pinned to IPFS automatically.
3. **Mint** an ERC-721 token linked to the IPFS hash.
4. **Trade** by listing the token for sale or transferring it directly.
5. **Track** the complete ownership history on-chain.

## Architecture

```mermaid
flowchart TB
    UI[React Frontend] -->|Web3.js| W[MetaMask]
    W --> SC[ERC-721 Smart Contract]
    UI -->|upload| IPFS[(IPFS)]
    SC -->|tokenURI| IPFS
```

<details>
<summary><b>Project structure</b></summary>

```text
NFTMarketGH/
├── contracts/          # Solidity smart contracts
├── migrations/         # Truffle deployment scripts
├── src/
│   ├── components/     # React UI components
│   ├── utils/          # Web3 helpers
│   └── App.js
├── test/               # Contract tests
└── truffle-config.js
```

</details>

## Tech Stack

| Layer | Technology |
|---|---|
| Smart contracts | ![Solidity](https://img.shields.io/badge/-Solidity-363636?style=flat-square&logo=solidity&logoColor=white) |
| Blockchain | ![Ethereum](https://img.shields.io/badge/-Ethereum-3C3C3D?style=flat-square&logo=ethereum&logoColor=white) |
| Frontend | ![React](https://img.shields.io/badge/-React-61DAFB?style=flat-square&logo=react&logoColor=black) |
| Storage | ![IPFS](https://img.shields.io/badge/-IPFS-65C2CB?style=flat-square&logo=ipfs&logoColor=black) |
| Web3 | ![Web3.js](https://img.shields.io/badge/-Web3.js-F16822?style=flat-square&logo=web3dotjs&logoColor=white) |
| Tooling | ![Truffle](https://img.shields.io/badge/-Truffle-5E464D?style=flat-square&logo=truffle&logoColor=white) ![npm](https://img.shields.io/badge/-npm-CB3837?style=flat-square&logo=npm&logoColor=white) |

## Roadmap

- [x] ERC-721 minting
- [x] IPFS storage
- [x] On-chain provenance
- [ ] Marketplace listings and offers
- [ ] Creator royalties (EIP-2981)
- [ ] Migrate to Hardhat or Foundry
- [ ] Mobile money on-ramp for local buyers

## Contributing

Contributions are welcome. For major changes, please open an issue first.

```bash
git checkout -b feature/your-feature
git commit -m "Add your feature"
git push origin feature/your-feature
```

Then open a Pull Request.

## License

Released under the [MIT License](LICENSE).

<div align="center">

<br />

Built with 🖤 in Ghana 🇬🇭 to empower local artists.

[![GitHub](https://img.shields.io/badge/-KelvCodes-181717?style=flat-square&logo=github&logoColor=white)](https://github.com/KelvCodes)

⭐ **Star this repo if you believe in African creators on-chain.**

</div>
