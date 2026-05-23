# Ethernaut Challenge 19 — Alien Codex

Exploiting a dynamic array length underflow to claim ownership of the contract.

Instance address:
```
0x017eEF20307984E6a01c56d84F7690bCd1eE9604
```

---

## 🎯 Goal

Claim ownership of the target `AlienCodex` contract.

---

## 🔎 Reading the Contract

The contract's state variables are laid out sequentially:
```solidity
contract AlienCodex is Ownable {
    bool public contact;     // slot 0 (along with owner address from Ownable)
    bytes32[] public codex;  // slot 1
    ...
```

* **Slot 0**: Stores both the `owner` address (20 bytes) and the `contact` boolean (1 byte) packed together.
* **Slot 1**: Stores the **length** of the dynamic array `codex`. The actual array elements are stored sequentially starting at `keccak256(1)`.

Inside `retract()`, the contract decrements the array length:
```solidity
    function retract() public contacted {
        codex.length--;
    }
```

Since this contract is compiled in Solidity `<0.6.0` without SafeMath, decrements are not checked for underflow. Calling `retract()` when `codex.length` is `0` underflows the length to $2^{256} - 1$. The array now spans the entire contract storage, enabling us to overwrite Slot 0!

---

## 🧠 Attack Strategy

1. **Make contact**: Call `makeContact()` to pass the `contacted` modifier.
2. **Underflow array length**: Call `retract()` to set the array length to $2^{256} - 1$, giving us write access to any storage slot.
3. **Calculate owner index**:
   The slot of `codex[i]` is:
   $$\text{Slot of codex}[i] = \text{keccak256}(1) + i$$
   To write to **Slot 0**, we solve:
   $$\text{keccak256}(1) + i = 0 \pmod{2^{256}}$$
   $$i = 2^{256} - \text{keccak256}(1)$$
4. **Overwrite owner**: Call `revise(i, player)` to overwrite Slot 0 with the player's address, instantly claiming ownership.

---

## 💻 Solution

### Using Forge Script

```bash
forge script script/19-AlienCodex.s.sol:AlienCodexSolution --rpc-url sepolia --broadcast
```

The [script](../../script/19-AlienCodex.s.sol) interacts directly with the target contract, underflows the array, computes the index, and overwrites the owner. No separate attacker contract is needed.

---

## 🛡️ Key Takeaway

- **Array underflow risks**: In Solidity `<0.8.0`, modifying array lengths directly can lead to storage-wide underflows that compromise contract state.
- **Checked arithmetic**: Always use newer Solidity versions (`>=0.8.0`) where checked arithmetic is active by default, or utilize SafeMath library versions for older compilers.

---

## 📜 My Transactions

- Contact Transaction: [0x65874fda6560de083c1ff41cdf01623b26480d66c9b0673cf4d19fd37d75acdf](https://sepolia.etherscan.io/tx/0x65874fda6560de083c1ff41cdf01623b26480d66c9b0673cf4d19fd37d75acdf)
- Array Underflow Transaction: [0x8760d2b30e396d4035421a004adde51b65d05b06de98634eb298a8fbef24e3e6](https://sepolia.etherscan.io/tx/0x8760d2b30e396d4035421a004adde51b65d05b06de98634eb298a8fbef24e3e6)
- Revise / Exploit Transaction: [0xe7f894cfb751cb8fc27ac2ddcf7f1b8c3013c2840cd420ee6a0f98cd9725bd5f](https://sepolia.etherscan.io/tx/0xe7f894cfb751cb8fc27ac2ddcf7f1b8c3013c2840cd420ee6a0f98cd9725bd5f)
