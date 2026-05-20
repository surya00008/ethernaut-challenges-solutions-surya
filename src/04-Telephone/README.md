# Ethernaut Challenge 04 — Telephone

Claim ownership of the contract.

Instance address:

```
0xc927513693b2007B789a3b1686954086EBE3f12D
```

---

## 🎯 Goal

1. Claim ownership of the contract

---

## 🔎 Reading the Contract

The contract has a single function to claim ownership:

```solidity
function changeOwner(address _owner) public {
    if (tx.origin != msg.sender) {
        owner = _owner;
    }
}
```

**The Vulnerability:**
To bypass the check, we need `tx.origin` to be different from `msg.sender`.

- **`tx.origin`**: The original externally owned account (EOA) wallet that signed and started the transaction chain.
- **`msg.sender`**: The immediate account (EOA or smart contract) that invoked the current function.

If you call this function directly from your wallet:
`Your Wallet` -> `Telephone`
Here, `tx.origin` is your wallet, and `msg.sender` is your wallet. They are equal. The check fails.

If you call it through a middleman smart contract:
`Your Wallet` -> `Middleman Contract` -> `Telephone`
Here, `tx.origin` is still your wallet, but `msg.sender` is the Middleman Contract. They are different. The check passes!

---

## 🧠 Attack Strategy

1. Deploy a custom attacker contract (`TelephoneAttacker.sol`).
2. Call `attacker.attack(playerAddress)` using your wallet.
3. The attacker contract executes `telephone.changeOwner(playerAddress)`.
4. The `if` condition passes and ownership is transferred to you.

---

## 💻 Solution

### Using Forge Script

```bash
forge script script/04-Telephone.s.sol --rpc-url sepolia --broadcast -vvv
```

The [script](../../script/04-Telephone.s.sol) automatically deploys the attacker contract and passes your player address to it, stealing ownership in a single transaction.

---

## 🛡️ Key Takeaway

- **Never use `tx.origin` for authorization.** Smart contracts can easily be tricked into bypassing `tx.origin` checks by using intermediate contracts.
- Always use `msg.sender` for authentication and authorization. `tx.origin` is generally only used for very specific edge cases (like preventing smart contracts from calling your function at all by requiring `require(tx.origin == msg.sender)`).

---

## 📜 My Transaction

https://sepolia.etherscan.io/tx/0x141ec141fe83a602e4ba54dafc4c008ddf3be357d1c1201ff81977683f19ab48
