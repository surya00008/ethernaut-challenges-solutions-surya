# Ethernaut Challenge 08 — Vault

Unlock the vault by reading its private password from on-chain storage.

Instance address:

```
0x67858382159F9dE5d926aeC27A43ef400fF66010
```

---

## 🎯 Goal

1. Unlock the `Vault` contract (change the `locked` variable from `true` to `false`).

---

## 🔎 Reading the Contract

The contract stores the password in a `private` variable:

```solidity
contract Vault {
    bool public locked;       // Stored in Storage Slot 0 (1 byte)
    bytes32 private password; // Stored in Storage Slot 1 (32 bytes)
    
    constructor(bytes32 _password) {
        locked = true;
        password = _password;
    }

    function unlock(bytes32 _password) public {
        if (password == _password) {
            locked = false;
        }
    }
}
```

Although the variable is marked as `private`, this only restricts access from **other contracts** at the compiler level. The state of public blockchains is completely open and transparent. Anyone can read any storage slot directly using a Node provider or helper tools.

---

## 🧠 Attack Strategy

1. Identify the storage slot of the `password` variable. Since `locked` is declared first and takes only 1 byte, it occupies the beginning of Slot 0. The `password` variable is a 32-byte `bytes32` value, so it is pushed to **Storage Slot 1**.
2. Read the raw value in Slot 1 using Foundry's `vm.load` cheatcode.
3. Call the `unlock()` function passing the loaded `password` value.

---

## 💻 Solution

### Using Forge Script

```bash
forge script script/08-Vault.s.sol --rpc-url sepolia --broadcast -vvvv
```

The [script](../../script/08-Vault.s.sol) automatically reads the raw storage from slot 1 and calls `unlock()` in a single sequence.

---

## 🛡️ Key Takeaway

- **Private visibility is not security**: Marking state variables as `private` or `internal` does not encrypt or hide them. All on-chain state data is completely public.
- **Do not store secrets on-chain**: Sensitive information (passwords, encryption keys, private credentials) must never be stored in plaintext on a public blockchain.

---

## 📜 My Transaction

- Unlock transaction: [0x79fec5d056cbe8f0af4f90bef4062aba0a1b0e389c5239374601d40db1d19dd1](https://sepolia.etherscan.io/tx/0x79fec5d056cbe8f0af4f90bef4062aba0a1b0e389c5239374601d40db1d19dd1)
