# 🛡️ Ethernaut Solutions by Surya

Smart contract security challenges from OpenZeppelin's Ethernaut CTF, solved using Foundry.

## 🎯 About
This repository documents my journey through the Ethernaut CTF challenges, showcasing vulnerability analysis, exploitation techniques, and smart contract security knowledge.

## ⚙️ Setup

### Prerequisites
- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- [MetaMask](https://metamask.io/) with Sepolia testnet
- Sepolia ETH from [faucet](https://sepoliafaucet.com/)

### Installation
```bash
# Clone the repository
git clone https://github.com/surya00008/ethernaut-solutions-surya.git
cd ethernaut-solutions-surya

# Install dependencies
forge install

# Set up environment
cp .env.example .env
# Edit .env with your credentials

# Import wallet (recommended over .env PRIVATE_KEY)
cast wallet import ethernaut --interactive
```

## 📂 Repository Structure
```
src/
  XX-ChallengeName/
    README.md              # Challenge writeup
    ChallengeName.sol      # Original contract
    AttackerContract.sol   # Attack contract (if needed)
    
script/
  XX-ChallengeName.s.sol   # Solution script
```

## 🚀 Usage

### Solving a Challenge
1. Get instance from [Ethernaut](https://ethernaut.openzeppelin.com/)
2. Copy instance address
3. Update the script with instance address
4. Run solution:
```bash
forge script script/01-Fallback.s.sol \
  --rpc-url sepolia \
  --broadcast \
  --account ethernaut
```
5. Submit instance on Ethernaut website

## 🧩 Progress

| # | Challenge | Status | Writeup |
|---|-----------|--------|---------|
| 00 | Hello Ethernaut | ✅ | [Link](./src/00-HelloEthernaut/README.md) |
| 01 | Fallback | ✅ | [Link](./src/01-Fallback/README.md) |
| 02 | Fallout | ✅ | [Link](./src/02-Fallout/README.md) |
| 03 | Coin Flip | ✅ | [Link](./src/03-CoinFlip/README.md) |
| 04 | Telephone | ✅ | [Link](./src/04-Telephone/README.md) |
| 05 | Token | ✅ | [Link](./src/05-Token/README.md) |
| 06 | Delegation | ✅ | [Link](./src/06-Delegation/README.md) |
| 07 | Force | ✅ | [Link](./src/07-Force/README.md) |
| 08 | Vault | ✅ | [Link](./src/08-Vault/README.md) |
| 09 | King | ✅ | [Link](./src/09-King/README.md) |
| 10 | Re-entrancy | ✅ | [Link](./src/10-Reentrancy/README.md) |
| 11 | Elevator | ✅ | [Link](./src/11-Elevator/README.md) |
| 12 | Privacy | ✅ | [Link](./src/12-Privacy/README.md) |
| 13 | Gatekeeper One | ✅ | [Link](./src/13-GatekeeperOne/README.md) |
| 14 | Gatekeeper Two | ✅ | [Link](./src/14-GatekeeperTwo/README.md) |
| 15 | Naught Coin | ✅ | [Link](./src/15-NaughtCoin/README.md) |
| 16 | Preservation | ✅ | [Link](./src/16-Preservation/README.md) |
| 17 | Recovery | ✅ | [Link](./src/17-Recovery/README.md) |
| 18 | Magic Number | ✅ | [Link](./src/18-MagicNumber/README.md) |
| 19 | Alien Codex | ✅ | [Link](./src/19-AlienCodex/README.md) |
| 20 | Denial | ✅ | [Link](./src/20-Denial/README.md) |
| 21 | Shop | ✅ | [Link](./src/21-Shop/README.md) |
| 22 | Dex | ✅ | [Link](./src/22-Dex/README.md) |
| 23 | Dex Two | ✅ | [Link](./src/23-DexTwo/README.md) |
| 24 | Puzzle Wallet | ✅ | [Link](./src/24-PuzzleWallet/README.md) |
| 25 | Motorbike | ✅ | [Link](./src/25-Motorbike/README.md) |
| 26 | Double Entry Point | ✅ | [Link](./src/26-DoubleEntryPoint/README.md) |
| 27 | Good Samaritan | ⬜ | [Link](./src/27-GoodSamaritan/README.md) |
| 28 | Gatekeeper Three | ⬜ | [Link](./src/28-GatekeeperThree/README.md) |
| 29 | Switch | ⬜ | [Link](./src/29-Switch/README.md) |
| 30 | Higher Order | ⬜ | [Link](./src/30-HigherOrder/README.md) |
| 31 | Stake | ⬜ | [Link](./src/31-Stake/README.md) |
| 32 | Impersonator | ⬜ | [Link](./src/32-Impersonator/README.md) |
| 33 | Magic Animal Carousel | ⬜ | [Link](./src/33-MagicAnimalCarousel/README.md) |
| 34 | Bet House | ⬜ | [Link](./src/34-BetHouse/README.md) |
| 35 | Elliptic Token | ⬜ | [Link](./src/35-EllipticToken/README.md) |
| 36 | Cashback | ⬜ | [Link](./src/36-Cashback/README.md) |
| 37 | Impersonator Two | ⬜ | [Link](./src/37-ImpersonatorTwo/README.md) |
| 38 | Unique NFT | ⬜ | [Link](./src/38-UniqueNFT/README.md) |
| 39 | Forger | ⬜ | [Link](./src/39-Forger/README.md) |
| 40 | Not Optimistic Portal | ⬜ | [Link](./src/40-NotOptimisticPortal/README.md) |

## 🔗 Resources
- [Ethernaut](https://ethernaut.openzeppelin.com/)
- [My Ethernaut Profile](https://ethernaut.openzeppelin.com/level/0x3c34A342b2aF5e885FcaA3800dB5B205fEfa3ffB)
- [Foundry Book](https://book.getfoundry.sh/)

## 👤 Author
**Surya Singu** - Blockchain Developer

- GitHub: [@surya00008](https://github.com/surya00008)
- LinkedIn: [contactsuryasingu](https://linkedin.com/in/contactsuryasingu)
- Portfolio: [surya-code.vercel.app](https://surya-code.vercel.app)
- Email: suryasingu008@gmail.com

## 📜 License
This project is for educational purposes only.
