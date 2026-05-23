# Ethernaut Challenge 14 — Gatekeeper Two

Pass through three distinct security gates to claim the title of entrant.

Instance address:
```
0xF632aa98D257815699Aa66C5c95f8b3592Ee222f
```

---

## 🎯 Goal

Register your `tx.origin` address as the `entrant` of the target `GatekeeperTwo` contract.

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
`msg.sender` must not be `tx.origin`. This is easily bypassed by calling the target contract from an intermediate smart contract.

### 2. Gate Two
```solidity
modifier gateTwo() {
    uint256 x;
    assembly {
        x := extcodesize(caller())
    }
    require(x == 0);
    _;
}
```
The caller's address bytecode size (`extcodesize`) must be exactly `0`.

Normally, calling from a smart contract returns `extcodesize > 0`. However, during contract deployment (inside the `constructor()` function), the contract's runtime bytecode is not yet saved to the blockchain state. Thus, inside the constructor, its `extcodesize` is exactly `0`. We must execute the attack within our attacker contract's constructor.

### 3. Gate Three
```solidity
modifier gateThree(bytes8 _gateKey) {
    require(uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == type(uint64).max);
    _;
}
```
The modifier takes the keccak256 hash of `msg.sender` (which is the address of `GatekeeperTwoAttacker`), casts it, and checks that its XOR (`^`) with `_gateKey` equals `type(uint64).max` (`0xFFFFFFFFFFFFFFFF`).

Because of the XOR property:
* If $A \oplus B = C$, then $A \oplus C = B$.
* Thus: `key = hash(msg.sender) ^ type(uint64).max`.

---

## 🧠 Attack Strategy

1. Deploy `GatekeeperTwoAttacker` pointing to the target contract.
2. In the attacker constructor:
   * Compute the `_gateKey` using the contract's own address (`address(this)`):
     `bytes8 key = bytes8(type(uint64).max ^ uint64(bytes8(keccak256(abi.encodePacked(address(this))))));`
   * Call `enter(key)` on the target contract.
3. Since all steps occur inside the constructor, `extcodesize` of the caller is `0`, successfully passing all three gates.

---

## 💻 Solution

### Using Forge Script

```bash
forge script script/14-GatekeeperTwo.s.sol:GatekeeperTwoSolution --rpc-url sepolia --broadcast
```

The [script](../../script/14-GatekeeperTwo.s.sol) deploys the separate [GatekeeperTwoAttacker.sol](./GatekeeperTwoAttacker.sol) contract to carry out the constructor-based attack.

---

## 🛡️ Key Takeaway

- **`extcodesize` is not a reliable safety check**: Checking `extcodesize == 0` is not an effective way to verify if an address is an EOA (Externally Owned Account) rather than a contract, since it is always `0` during a contract's constructor execution.
- **XOR logic**: Ensure cryptographic checks do not rely on simple reversible bitwise operations like XOR unless combined with strong mathematical primitives.

---

## 📜 My Transactions

- Attacker Contract Deploy & Attack: [0x812471389cc3db62258db8d3ff69c007c2a31269c07b8fdd2d18ffa536387b31](https://sepolia.etherscan.io/tx/0x812471389cc3db62258db8d3ff69c007c2a31269c07b8fdd2d18ffa536387b31)
