# Ethernaut Challenge 13 — Gatekeeper One

Pass through three distinct security gates to claim the title of entrant.

Instance address:
```
0x3be7E01eB665d6d2C0B9113D9F642352a7e59A53
```

---

## 🎯 Goal

Register your `tx.origin` address as the `entrant` of the target `GatekeeperOne` contract.

---

## 🔎 Reading the Contract

To enter the contract, we must satisfy three modifiers in a single transaction:

### 1. Gate One
```solidity
modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
}
```
`msg.sender` must not be `tx.origin`. This is easily satisfied by calling the target contract from an intermediate smart contract.

### 2. Gate Two
```solidity
modifier gateTwo() {
    require(gasleft() % 8191 == 0);
    _;
}
```
The remaining gas at the point of checking `gasleft()` must be a multiple of `8191`.

Because gas consumption varies depending on compiler versions, compiler optimizer configurations, and EVM changes, we can solve this by brute forcing the gas offset. We send a base gas amount `(8191 * multiplier)` and try offsets `0` to `8190` in a loop inside an attacker contract call until it succeeds.

### 3. Gate Three
```solidity
modifier gateThree(bytes8 _gateKey) {
    require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
    require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
    require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), "GatekeeperOne: invalid gateThree part three");
    _;
}
```
We must craft an 8-byte key (`_gateKey`) that satisfies three properties:
1. `uint32(key) == uint16(key)`: The lower 4 bytes must equal the lower 2 bytes. This is represented in hex as `0x0000XXXX`.
2. `uint32(key) != uint64(key)`: The total 8-byte key must not equal the lower 4 bytes. Thus, the upper 4 bytes must be non-zero (e.g. `0x12345678`).
3. `uint32(key) == uint16(uint160(tx.origin))`: The lower 2 bytes of the key must equal the lower 2 bytes of your transaction origin address (`tx.origin`).

Combining these requirements:
* `bytes8 key = bytes8(uint64(0x1234567800000000) | uint64(uint16(uint160(tx.origin))))`

---

## 🧠 Attack Strategy

1. Deploy `GatekeeperOneAttacker` pointing to the target contract.
2. In `attack()`, craft the `_gateKey` using the `tx.origin` address bytes.
3. Run a loop from `0` to `8191` performing low-level calls to the target with gas set to `(8191 * 3) + i` where `i` is the current loop index offset.
4. When a call returns `true` (indicating successful entry), the loop terminates and the exploit is complete.

---

## 💻 Solution

### Using Forge Script

```bash
forge script script/13-GatekeeperOne.s.sol:GatekeeperOneSolution --rpc-url sepolia --broadcast -vvvv
```

The [script](../../script/13-GatekeeperOne.s.sol) deploys the separate [GatekeeperOneAttacker.sol](./GatekeeperOneAttacker.sol) contract to carry out the brute-force attack.

---

## 🛡️ Key Takeaway

- **Gas-dependent logic is fragile**: Do not use exact gas left (`gasleft()`) as a security control or gate requirement, as compiler configurations, gas schedules, or EVM forks can easily alter gas consumption and introduce vulnerabilities or break behavior.
- **Contract access controls**: Make sure `msg.sender != tx.origin` is not the only check used to identify whether the caller is a contract, as it doesn't represent standard authentication.
- **Type-casting values**: Be extremely careful with narrowing type-casts (e.g., casting `uint64` to `uint32` or `uint16`) as they mask upper bytes and can easily bypass checks if not validated fully.

---

## 📜 My Transactions

- Attacker Contract Deploy: [0x2f611a7c27e63384c90af7df4c9daa9b73d8e6305ff339e32153c6bed2551ccc](https://sepolia.etherscan.io/tx/0x2f611a7c27e63384c90af7df4c9daa9b73d8e6305ff339e32153c6bed2551ccc)
- Exploit Transaction: [0x9324ca7ff019be7280e8225cb41b647aa326d2f048648fa856b5e199006d4dd5](https://sepolia.etherscan.io/tx/0x9324ca7ff019be7280e8225cb41b647aa326d2f048648fa856b5e199006d4dd5)
