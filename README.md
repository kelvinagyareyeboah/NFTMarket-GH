# NFTMarket GH

**A decentralized NFT minting and trading platform built for Ghanaian artists.**

NFTMarket GH bridges the gap between African creativity and blockchain technology — giving local artists a transparent, trustless way to tokenize, showcase, and sell their work.

---

## Features

- **ERC-721 NFT Minting** — Mint unique, standards-compliant tokens from any artwork
- **IPFS Decentralized Storage** — Assets stored off-chain, permanently and censorship-resistant
- **Ownership History** — Full provenance tracking on the Ethereum Rinkeby testnet
- **React Frontend** — Clean, responsive UI for browsing, minting, and trading
- **Web3 Integration** — Connect your wallet and interact with the blockchain seamlessly

---

## Tech Stack

| Layer | Technology |
|---|---|
| Smart Contracts | Solidity (ERC-721) |
| Blockchain | Ethereum — Rinkeby Testnet |
| Frontend | React |
| Storage | IPFS |
| Web3 Integration | Web3.js |

---

## Getting Started

### Prerequisites

- Node.js ≥ 16
- Truffle (`npm install -g truffle`)
- MetaMask browser extension
- Rinkeby testnet ETH ([faucet](https://faucets.chain.link/rinkeby))

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

Open [http://localhost:3000](http://localhost:3000) and connect your MetaMask wallet to mint your first NFT.

---

## How It Works

1. **Connect** your MetaMask wallet to the Rinkeby testnet
2. **Upload** your artwork — it's pinned to IPFS automatically
3. **Mint** an ERC-721 token tied to your piece
4. **Trade** — list it for sale or transfer ownership directly
5. **Track** the full ownership history on-chain, forever

---

## Project Structure

```
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

---

## Contributing

Contributions are welcome! To get started:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m "Add your feature"`
4. Push and open a Pull Request

Please open an issue first for major changes.

---

## License

[MIT](LICENSE) — free to use, modify, and distribute.

---

*Built with 🖤 to empower Ghanaian artists on the blockchain.*
