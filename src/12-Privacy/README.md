# Ethernaut Challenge 12 — Privacy

Unlock the contract by reading the key from a private variable stored in contract storage.

Instance address:
```
0x91e6a7EA8497EBE78fE75A2d8dA21ad780C4fE34
```

---

## 🎯 Goal

Unlock the target `Privacy` contract by passing the correct `bytes16` key to `unlock()`.

---

## 🔎 Reading the Contract

The contract defines several private variables:
```solidity
    bool public locked = true;
    uint256 public ID = block.timestamp;
    uint8 private flattening = 10;
    uint8 private denomination = 255;
    uint16 private awkwardness = uint16(block.timestamp);
    bytes32[3] private data;
```

We need to match the key check:
```solidity
    function unlock(bytes16 _key) public {
        require(_key == bytes16(data[2]));
        locked = false;
    }
```

Since variables are private, we cannot access them via contract calls. However, all smart contract state variables are public on the blockchain and laid out sequentially in 32-byte storage slots:

1. **Slot 0**: `locked` (bool - 1 byte)
2. **Slot 1**: `ID` (uint256 - 32 bytes)
3. **Slot 2**: `flattening` (uint8 - 1 byte), `denomination` (uint8 - 1 byte), `awkwardness` (uint16 - 2 bytes) - packed together to save gas.
4. **Slot 3**: `data[0]` (bytes32 - 32 bytes)
5. **Slot 4**: `data[1]` (bytes32 - 32 bytes)
6. **Slot 5**: `data[2]` (bytes32 - 32 bytes) <-- We need this slot!

---

## 🧠 Attack Strategy

1. Read the raw 32-byte value from **Storage Slot 5** using a tool or cheatcode like `vm.load(INSTANCE, bytes32(uint256(5)))`.
2. Convert the 32-byte value to the first 16 bytes using `bytes16(data2)`.
3. Call `unlock()` on the target contract with the derived key.

---

## 💻 Solution

### Using Forge Script

```bash
forge script script/12-Privacy.s.sol:PrivacySolution --rpc-url sepolia --broadcast
```

The [script](../../script/12-Privacy.s.sol) utilizes Foundry's cheatcodes to load the slot, extract the key, and call `unlock()`.

---

## 🛡️ Key Takeaway

- **Privacy on-chain does not exist**: Declaring a variable as `private` only prevents other contracts from accessing it directly. Anyone can inspect your contract's storage layout off-chain to read all private data.
- **Do not store secrets in plaintext**: Never store sensitive passwords, API keys, or private data in plaintext within smart contract variables.

---

## 📜 My Transactions

- Unlock Exploit Transaction: [0x511972372a84155d6a98a24a15f91e0cf1121ef2e9877f466db51b857884b871](https://sepolia.etherscan.io/tx/0x511972372a84155d6a98a24a15f91e0cf1121ef2e9877f466db51b857884b871)
