# Ethernaut Challenge 10 — Reentrancy

Drain all the contract's funds.

Instance address:
```
0x9aE502233705C85BA2774A4Fe194D950033c8F93
```

---

## 🎯 Goal

1. Empty the target contract `Reentrance` of all its ether.

---

## 🔎 Reading the Contract

The vulnerability lies in the `withdraw` function of `Reentrance`:

```solidity
    function withdraw(uint256 _amount) public {
        if (balances[msg.sender] >= _amount) {
            (bool result,) = msg.sender.call{value: _amount}("");
            if (result) {
                _amount;
            }
            balances[msg.sender] -= _amount;
        }
    }
```

This function violates the **Checks-Effects-Interactions** pattern:
1. **Check**: It checks if `balances[msg.sender] >= _amount`.
2. **Interaction**: It performs an external call `msg.sender.call{value: _amount}("")` to transfer the Ether *before* updating the user's balance.
3. **Effect**: It updates the balance `balances[msg.sender] -= _amount` *after* the external call is complete.

Since the external call transfers control to the recipient before the balance is decremented, a malicious contract can re-enter the `withdraw` function inside its fallback function (`receive` or `fallback`), executing subsequent withdrawals while its recorded balance remains unchanged.

---

## 🧠 Attack Strategy

1. Deploy an attacker contract (`AttackReentrant`) with the address of the target contract.
2. The attacker contract donates a small amount of ether to itself via `donate{value: 0.001 ether}(address(this))` to establish a non-zero balance inside the target contract.
3. The attacker contract calls `withdraw(0.001 ether)` on the target.
4. When the target contract sends the `0.001 ether` using `call{value: _amount}("")`, control is shifted to the attacker's `receive` function.
5. Inside `receive()`, the attacker contract re-enters `reentranceInstance.withdraw(0.001 ether)` again.
6. The target contract sees the attacker's balance is still `0.001 ether` (since the first withdraw hasn't decremented the balance yet) and proceeds to send another `0.001 ether`.
7. This re-entrancy repeats recursively until the target contract's total balance is completely drained.
8. Once the target contract is drained, the transfer fails, the recursion stops, the stack unwinds, and the attacker contract transfers the stolen funds back to the player.

---

## 💻 Solution

### Using Forge Script

```bash
forge script script/10-Reentrancy.s.sol:ReentrancySolution --rpc-url sepolia --broadcast
```

The script [10-Reentrancy.s.sol](../../script/10-Reentrancy.s.sol) deploys the `AttackReentrant` contract and executes the `withdraw()` exploit.

---

## 🛡️ Key Takeaway

- **Checks-Effects-Interactions Pattern**: Always update all internal state variables (effects) *before* executing external calls or transfers (interactions).
- **Use ReentrancyGuards**: Utilize OpenZeppelin's `nonReentrant` modifier to restrict functions from being called recursively.
- **Pull over Push**: Always prioritize pull-based withdrawal payments rather than direct state-transition pushes.

---

## 📜 My Transactions

- Attacker Contract Deploy: [0x8bfa0f5735d74bc2aa4c7b35f2398df01930dd9564b6ca5e696a955de03a3528](https://sepolia.etherscan.io/tx/0x8bfa0f5735d74bc2aa4c7b35f2398df01930dd9564b6ca5e696a955de03a3528)
- Exploit Transaction: [0x3290182230d21163abbe088390dd9aa6acbcbf482bff25af88ce2bc57e85c57a](https://sepolia.etherscan.io/tx/0x3290182230d21163abbe088390dd9aa6acbcbf482bff25af88ce2bc57e85c57a)
