# Ethernaut Challenge 09 — King

Claim kingship and permanently secure it against dethronement via a Denial of Service attack.

Instance address:

```
0xc6f44D0372cC16Af05DedFBeF8Af27F3b7A9A845
```

---

## 🎯 Goal

1. Claim kingship of the target `King` contract.
2. Prevent anyone else (including the game master/admin) from reclaiming the kingship.

---

## 🔎 Reading the Contract

The contract changes kings inside the `receive()` function:

```solidity
receive() external payable {
    require(msg.value >= prize || msg.sender == owner);
    payable(king).transfer(msg.value);
    king = msg.sender;
    prize = msg.value;
}
```

When a new king sends enough Ether to dethrone the old king:
1. The contract pays back the old king by calling `payable(king).transfer(msg.value);`.
2. The sender is crowned the new `king`.

In Solidity, the `.transfer()` call is safe but will **throw an error and revert the entire transaction** if the recipient address rejects the incoming Ether transfer.

---

## 🧠 Attack Strategy

By deploying an attacker contract as the King, we can exploit the strict behavior of `.transfer()` to create a Denial of Service (DoS):

1. Deploy an attacker contract (`KingAttacker.sol`).
2. Implement a `receive()` function in the attacker contract that always calls `revert()`.
3. Call `changeKing()` on the attacker contract sending a payment greater than or equal to the current `prize`. The attacker contract sends this ETH to the `King` contract and successfully claims kingship.
4. When another user or the Ethernaut engine attempts to dethrone the attacker contract, the `King` contract tries to refund the attacker contract using `payable(king).transfer(msg.value)`.
5. The attacker contract reverts the transfer inside its `receive()` fallback.
6. The refund fails, causing the entire dethronement transaction to revert. The attacker remains king forever.

---

## 💻 Solution

### Using Forge Script

```bash
forge script script/09-King.s.sol --rpc-url sepolia --broadcast -vvvv
```

The [script](../../script/09-King.s.sol) deploys the [KingAttacker.sol](./KingAttacker.sol) contract and uses it to capture the kingship.

---

## 🛡️ Key Takeaway

- **Avoid the Push Payment pattern**: Writing contracts that automatically send Ether to external addresses during a state transition is dangerous. If any external call reverts, the entire function is blocked.
- **Use the Pull Payment pattern**: Design contracts where users must pull/withdraw their own refunds or rewards manually in separate transactions.

---

## 📜 My Transactions

- Attacker Contract Deploy: [0x4042daca8da67d3beea745c66af0b057b09a7753e69d23ee2c6e8bde3282443f](https://sepolia.etherscan.io/tx/0x4042daca8da67d3beea745c66af0b057b09a7753e69d23ee2c6e8bde3282443f)
- Takeover Kingship: [0xe44cfc3fe3c54b7af88ff04a9331924fcd31a55eeec6b2f4a199d43fe07fce8a](https://sepolia.etherscan.io/tx/0xe44cfc3fe3c54b7af88ff04a9331924fcd31a55eeec6b2f4a199d43fe07fce8a)
