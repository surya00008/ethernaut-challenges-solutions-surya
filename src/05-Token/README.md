# Ethernaut Challenge 05 — Token

Hack the basic token contract to obtain a massive number of tokens.

Instance address:

```
0x92A0C83D2Fa19cF33E7Fd99901C4595e17b49147
```

---

## 🎯 Goal

1. Hack the token contract to increase your balance of 20 tokens to a massive amount

---

## 🔎 Reading the Contract

The vulnerability lies in the `transfer` function of the contract:

```solidity
function transfer(address _to, uint256 _value) public returns (bool) {
    require(balances[msg.sender] - _value >= 0);
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    return true;
}
```

1. **Solidity Version**: The contract uses Solidity version `^0.6.0`. In versions prior to `0.8.0`, arithmetic operations do not automatically revert on overflow/underflow.
2. **Flawed Validation**: The check `require(balances[msg.sender] - _value >= 0)` uses unsigned integer subtraction. Because a `uint256` cannot represent negative numbers, `balances[msg.sender] - _value` underflows and wraps around to a massive positive number (close to `2^256`) when `_value` is greater than the sender's balance. This means the condition is *always* true (i.e. `>= 0`), and the `require` statement is bypassed.
3. **State Corruption**: In `balances[msg.sender] -= _value;`, the sender's balance underflows, wrapping around to a massive value: `20 - 21 = 2^256 - 1`.

---

## 🧠 Attack Strategy

1. Since we start with `20` tokens, we can call `transfer` with a `_value` of `21` to any recipient address (like `address(1)`).
2. The subtraction `20 - 21` underflows to `2^256 - 1`, giving us a nearly infinite balance.
3. The check `20 - 21 >= 0` evaluates to `(2^256 - 1) >= 0`, which is true, allowing the transaction to succeed.

---

## 💻 Solution

### Using Forge Script

```bash
forge script script/05-Token.s.sol --rpc-url sepolia --broadcast
```

The [script](../../script/05-Token.s.sol) calls the `transfer` function with a value of `21` to trigger the underflow.

---

## 🛡️ Key Takeaway

- **Arithmetic Safety**: Always use Solidity `>= 0.8.0` where overflow/underflow check is built-in by default, or use OpenZeppelin's `SafeMath` library for older compiler versions.
- **Tautological Checks**: Never check if a `uint` subtraction is greater than or equal to `0` (`a - b >= 0`) to enforce balance requirements. Unsigned integers are always non-negative. Instead, use a direct comparison: `require(balances[msg.sender] >= _value)`.

---

## 📜 My Transaction

https://sepolia.etherscan.io/tx/0x365cfa3c8f9c4c8bce5148643f9f8e13d3091cb4db4d6eb349ec34f6c0c4b267
