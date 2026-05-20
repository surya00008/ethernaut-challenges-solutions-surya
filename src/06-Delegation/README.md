# Ethernaut Challenge 06 — Delegation

Claim ownership of the contract.

Instance address:

```
0x2704E9571138C091de1ae77070659E030e0725d9
```

---

## 🎯 Goal

1. Claim ownership of the contract

---

## 🔎 Reading the Contract

The `Delegation` contract implements a custom `fallback()` function that forwards all incoming execution calls to a helper `Delegate` contract using `delegatecall`:

```solidity
fallback() external {
    (bool result,) = address(delegate).delegatecall(msg.data);
    if (result) {
        this;
    }
}
```

The `delegatecall` EVM opcode preserves the execution context (caller, origin, storage, address, and value) of the calling contract. When `Delegation` executes code from `Delegate` via `delegatecall`, the code runs inside the context of `Delegation`. This means any state modifications made by the `Delegate` code are applied directly to the storage slots of the `Delegation` contract.

The `Delegate` contract has a `pwn()` function:

```solidity
function pwn() public {
    owner = msg.sender;
}
```

Both contracts define `owner` as their first state variable (residing in storage slot `0`). Calling `pwn()` via `delegatecall` inside `Delegation` overwrites slot `0` of the calling context, setting `owner` to `msg.sender`.

---

## 🧠 Attack Strategy

1. Construct a transaction targeting the `Delegation` contract.
2. Set the transaction's payload (`msg.data`) to the function selector of `pwn()`, which is `abi.encodeWithSignature("pwn()")`.
3. Send the transaction. The `Delegation` contract does not define a `pwn()` function, triggering the `fallback()` function.
4. The `fallback()` function executes the `delegatecall` to the `Delegate` contract, running `pwn()` in the `Delegation` storage context.
5. Storage slot `0` of the `Delegation` contract is overwritten, claiming ownership.

---

## 💻 Solution

### Using Forge Script

```bash
forge script script/06-Delegation.s.sol --rpc-url sepolia --broadcast
```

The [script](../../script/06-Delegation.s.sol) executes the attack by invoking `call()` on the `Delegation` contract with the payload `abi.encodeWithSignature("pwn()")`.

---

## 🛡️ Key Takeaway

- **Delegatecall Risks**: `delegatecall` is an incredibly powerful opcode but extremely dangerous. Never delegate execution to arbitrary or untrusted contracts.
- **Storage Layout Matches**: When using `delegatecall`, ensure both contracts share exact matching storage layouts to prevent unintended slot corruption.

---

## 📜 My Transaction

https://sepolia.etherscan.io/tx/0x5e4ade8fbc0d52ecb0c70c4f31643ee44e3d1d23f0afe528ec8dcd6673f3e564
