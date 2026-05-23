# Ethernaut Challenge 17 — Recovery

Recovering lost Ether by locating a deterministically deployed contract address and self-destructing it.

Instance address:
```
0x3e450F0a84569e63027897Da8Fa35a8fBa7ED6C3
```

---

## 🎯 Goal

Recover `0.001 ETH` that was sent to a lost `SimpleToken` contract.

---

## 🔎 Reading the Contract

The main contract `Recovery` deploys `SimpleToken` inside `generateToken`:
```solidity
    function generateToken(string memory _name, uint256 _initialSupply) public {
        new SimpleToken(_name, msg.sender, _initialSupply);
    }
```

The `SimpleToken` contract contains a cleanup function:
```solidity
    // clean up after ourselves
    function destroy(address payable _to) public {
        selfdestruct(_to);
    }
```

Since `destroy` is public and lacks authorization checks, calling `destroy(payable(player))` on the correct address immediately triggers a `selfdestruct`, sending the contract's entire balance back to the player.

---

## 🧠 Address Computation Strategy

Under Ethereum's EVM, address creation is **fully deterministic**. When a contract deploys another contract using the standard `new` keyword (which triggers the `CREATE` opcode), the address is computed as:
$$\text{address} = \text{keccak256}(\text{RLP}([\text{sender}, \text{nonce}]))[12\dots 31]$$

Where:
* **sender**: The address of the deploying `Recovery` contract (`INSTANCE`).
* **nonce**: The transaction count (nonce) of the deploying contract at the time of creation. Since this was the first contract `Recovery` deployed, its nonce was exactly `1`.

For a sender address and a 1-byte nonce of `1`, the RLP encoding of the list is defined as:
* `0xd6` (length of list header)
* `0x94` (length of sender address header = 20 bytes)
* `sender` (20 bytes address)
* `0x01` (nonce value of `1`)

Thus, the exact RLP payload to hash is:
`abi.encodePacked(bytes1(0xd6), bytes1(0x94), INSTANCE, bytes1(0x01))`

By calculating this hash inside our Solidity script, we recover the lost address and execute `destroy()` to reclaim the Ether!

---

## 💻 Solution

### Using Forge Script

```bash
forge script script/17-Recovery.s.sol:RecoverySolution --rpc-url sepolia --broadcast
```

The [script](../../script/17-Recovery.s.sol) computes the lost token address, outputs it, and calls `destroy()`. No separate attacker contract is needed.

---

## 🛡️ Key Takeaway

- **Addresses are deterministic**: Smart contract addresses are not random; they can be pre-computed and tracked easily, even if the creator loses the deployment record.
- **`selfdestruct` deprecation**: Understand that starting from the Cancun hard fork, `selfdestruct` has been deprecated and its functionality is limited to transferring the contract's Ether balance to the beneficiary address without deleting the code (EIP-6780).
- **Access control on destruction**: Never leave sensitive operations like contract destruction or balance transfers completely public without strong access control modifiers.

---

## 📜 My Transactions

- Recover & Destroy Transaction: [0x5a32defdfacb381d5e21b80d885edf532bc493e43797546082ceab08c7753b68](https://sepolia.etherscan.io/tx/0x5a32defdfacb381d5e21b80d885edf532bc493e43797546082ceab08c7753b68)
