# Ethernaut Challenge 11 — Elevator

Tricking the elevator to go to the top floor.

Instance address:
```
0xEE4BFC9b772316458895ca96736D1E531ed097ca
```

---

## 🎯 Goal

Set the `top` state variable in the target `Elevator` contract to `true`.

---

## 🔎 Reading the Contract

The `Elevator` contract contains the following logic:

```solidity
    function goTo(uint256 _floor) public {
        Building building = Building(msg.sender);

        if (!building.isLastFloor(_floor)) {
            floor = _floor;
            top = building.isLastFloor(floor);
        }
    }
```

The function queries `building.isLastFloor(_floor)` twice:
1. `if (!building.isLastFloor(_floor))` - It must return `false` here so we enter the block.
2. `top = building.isLastFloor(floor)` - It must return `true` here so the state variable `top` is set to `true`.

Since the `Building` interface has state mutability undefined, we can deploy a custom `Building` contract that implements `isLastFloor` to return different boolean results on consecutive calls!

---

## 🧠 Attack Strategy

1. Implement `Building` interface in an attacker contract `ElevatorAttacker`.
2. Define a state variable `s_flip = false` that toggles on every call to `isLastFloor`.
3. In `isLastFloor`, return the current value of `s_flip` and invert it:
   * First call returns `false` (negated to `true` by the `!`, letting us enter the block).
   * Second call returns `true` (making `top` equal `true`).
4. Call `goTo(0)` from the attacker contract.

---

## 💻 Solution

### Using Forge Script

```bash
forge script script/11-Elevator.s.sol:ElevatorSolution --rpc-url sepolia --broadcast
```

The [script](../../script/11-Elevator.s.sol) compiles and deploys the attacker, triggering the `goTo()` state manipulation.

---

## 🛡️ Key Takeaway

- **Never rely on external contract states**: Avoid trusting external calls to return consistent or honest values, especially when the called interface has mutable state.
- **Interface safety**: Ensure that interface functions are marked with `view` or `pure` when you expect read-only behavior.

---

## 📜 My Transactions

- Attacker Contract Deploy: [0xf473f5755c67fe2c74480d153e02a2c8b2653ba30064973f7f7433920e11644b](https://sepolia.etherscan.io/tx/0xf473f5755c67fe2c74480d153e02a2c8b2653ba30064973f7f7433920e11644b)
- Exploit Transaction: [0xcf834802991e4c56949c792801965cc87d046e6fbc0524b26556a93d5413058b](https://sepolia.etherscan.io/tx/0xcf834802991e4c56949c792801965cc87d046e6fbc0524b26556a93d5413058b)
