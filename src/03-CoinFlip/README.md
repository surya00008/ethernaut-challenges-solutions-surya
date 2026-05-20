# Ethernaut Challenge 03 — CoinFlip

Predict the outcome of a coin flip 10 times in a row.

Instance address:

```
[To be filled with your instance address]
```

---

## 🎯 Goal

1. Call the `flip(bool _guess)` function
2. Guess the correct outcome 10 times consecutively

---

## 🔎 Reading the Contract

The contract generates a "random" boolean using the `blockhash` of the previous block:

```solidity
uint256 blockValue = uint256(blockhash(block.number - 1));
...
uint256 coinFlip = blockValue / FACTOR;
bool side = coinFlip == 1 ? true : false;
```

It then compares your `_guess` against `side`. If you are correct, `consecutiveWins` increments. If you are wrong, it resets to 0.

**The Vulnerability:**  
In Ethereum, data like `blockhash` and `block.number` are globally accessible. They are **not private** and they are **not secure sources of randomness**. Because our smart contract execution happens *in the exact same block* as the target contract's execution, the `block.number` and `blockhash` are identical for both.

---

## 🧠 Attack Strategy

1. Deploy an attacker contract (`CoinFlipAttacker.sol`).
2. Have the attacker contract read the exact same `blockhash(block.number - 1)` that the Ethernaut contract will read.
3. Have the attacker calculate the correct answer `side`.
4. The attacker contract then forwards that pre-calculated correct answer to the Ethernaut contract's `flip()` function.
5. Because everything happens in a single transaction within the same block, the prediction is guaranteed to be 100% correct.
6. Repeat this process 10 times across 10 different blocks.

---

## 💻 Solution

### Using Forge Script

```bash
forge script script/03-CoinFlip.s.sol --tc CoinFlipSolution --rpc-url sepolia --broadcast -vvv
```

The [script](../../script/03-CoinFlip.s.sol) automatically detects if the attacker contract is already deployed. If not, it deploys it and executes the first attack. On subsequent runs, it uses the existing attacker contract to execute the remaining attacks. Run this command 10 times (waiting for a new block to be mined each time).

---

## 🛡️ Key Takeaway

- **Never use block data for randomness.** `blockhash`, `block.timestamp`, `block.number`, etc. can be read and manipulated by miners, and can easily be calculated by other smart contracts executing in the same block.
- If you need secure randomness on-chain, use a decentralized oracle network like **Chainlink VRF** (Verifiable Random Function).

---

## 📜 My Transaction

https://sepolia.etherscan.io/tx/0x74cf8d795666f3964a860b40ec8b4adc09be81714643fa4252d55439876f5ffd
