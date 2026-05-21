# Ethernaut Challenge 07 — Force

Force-send Ether to a contract that does not accept incoming transactions.

Instance address:

```
0x894e78c9155e3C38CeC91e9dFC9F16418F21a74d
```

---

## 🎯 Goal

1. Make the balance of the `Force` contract greater than zero.

---

## 🔎 Reading the Contract

The contract is completely empty:

```solidity
contract Force {
    /*
                   MEOW ?
         /\_/\   /
    ____/ o o \
   /~____  =ø= /
  (______)__m_m)
                   */
}
```

Since it does not implement `receive()` or `fallback()` functions, any standard transaction sending Ether to it will fail and revert.

---

## 🧠 Attack Strategy

In the EVM, there are a few ways to force-send Ether to a contract even if it refuses to accept it. The most common and direct method is `selfdestruct`.

1. Deploy an attacker contract (`ForceAttacker.sol`).
2. Send some Ether to the attacker contract.
3. Call a function on the attacker contract that triggers `selfdestruct` with the target `Force` contract as the beneficiary.
4. When `selfdestruct(target)` is called, the attacker contract's code is deleted and its full Ether balance is immediately transferred to the `Force` contract. The EVM does not execute any code on the recipient address during this transfer.

---

## 💻 Solution

### Using Forge Script

```bash
forge script script/07-Force.s.sol --rpc-url sepolia --broadcast -vvvv
```

The [script](../../script/07-Force.s.sol) executes the attack using the attacker contract [ForceAttacker.sol](./ForceAttacker.sol).

---

## 🛡️ Key Takeaway

- **No contract can block incoming ETH entirely**: A contract does not need to declare itself `payable`, or have `receive()` / `fallback()` functions to receive Ether.
- **Never rely on strict balance checks**: Using `address(this).balance` in critical access control or state logic (e.g. `require(address(this).balance == 0)`) introduces a severe denial of service (DoS) vulnerability.

---

## 📜 My Transactions

- Attacker Contract Deploy: [0x691ae165ebdec4f39c7c116afa1eeb918b7f81436c12bd8db7247e2f4c5a47db](https://sepolia.etherscan.io/tx/0x691ae165ebdec4f39c7c116afa1eeb918b7f81436c12bd8db7247e2f4c5a47db)
- Funding Attacker: [0x2294c569ed0ee2b97bc3840f231668d51c65230719a4e9f2bf77134deefc51f7](https://sepolia.etherscan.io/tx/0x2294c569ed0ee2b97bc3840f231668d51c65230719a4e9f2bf77134deefc51f7)
- Exploit Execution: [0xc587e36f95741391326b5d64360a1f3cbc8e70a8b5ee6d1d703cdcc8a7b4167f](https://sepolia.etherscan.io/tx/0xc587e36f95741391326b5d64360a1f3cbc8e70a8b5ee6d1d703cdcc8a7b4167f)
