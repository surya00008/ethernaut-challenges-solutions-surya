# Ethernaut Challenge 00 — Hello Ethernaut

The introductory Ethernaut challenge. The objective is to interact with a smart contract on-chain and call `authenticate()` with the correct password.

Instance address:

```
0xC7f04316A16A154e75074f7dcFEC36B5029725F3
```

---

## 🎯 Goal

The challenge is solved when:

```solidity
cleared == true
```

This happens when the correct password is passed to `authenticate(string)`.

---

## 🔎 Reading the Contract

The contract has a series of breadcrumb functions:

```
info() → info1() → info2("hello") → info42() → method7123949()
```

Following these hints leads us to the final step: calling `authenticate()` with the correct password.

The key observation is that `password` is a **public state variable**:

```solidity
string public password;
```

In Solidity, public state variables automatically generate getter functions. This means anyone can read the password directly — **nothing on-chain is truly private**.

---

## 🧠 Solution

1. Call `password()` to read the value stored on-chain
2. Pass it to `authenticate()` to set `cleared = true`

### Using Foundry (cast)

Read the password:

```bash
cast call $INSTANCE "password()" --rpc-url $SEPOLIA_RPC_URL
```

Submit it:

```bash
cast send $INSTANCE "authenticate(string)" "ethernaut0" \
  --rpc-url $SEPOLIA_RPC_URL \
  --account ethernaut
```

### Using Forge Script

```bash
forge script script/00-HelloEthernaut.s.sol --rpc-url sepolia --broadcast -vvvv
```

The [script](../../script/00-HelloEthernaut.s.sol) reads the password on-chain and calls `authenticate()` in a single transaction.

---

## 🛡️ Key Takeaway

- `private` and public visibility in Solidity only restrict **contract-level** access
- All on-chain storage is publicly readable by anyone
- Never store secrets in plaintext on-chain

---

## 📜 My Transaction

https://sepolia.etherscan.io/tx/0xd1904c90b88a0f14be10107f957b14ba443de86bcefa07741db77c56e529d21d
