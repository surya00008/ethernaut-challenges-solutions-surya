# Ethernaut Challenge 15 — Naught Coin

Draining all the timelocked ERC20 tokens before the timelock expires.

Instance address:
```
0x6b1754DEe39addCBd33C3b894Bcf5C1D469845C9
```

---

## 🎯 Goal

Drain the entire `NaughtCoin` balance (1,000,000 tokens) from the player's account to bypass the 10-year timelock.

---

## 🔎 Reading the Contract

The contract overrides the ERC20 `transfer` function:

```solidity
    function transfer(address _to, uint256 _value) public override lockTokens returns (bool) {
        super.transfer(_to, _value);
    }

    modifier lockTokens() {
        if (msg.sender == player) {
            require(block.timestamp > timeLock);
            _;
        } else {
            _;
        }
    }
```

The `lockTokens` modifier intercepts any direct `transfer()` calls made by the player (`msg.sender == player`) and reverts the transaction unless the 10-year timelock has elapsed.

However, standard ERC20 tokens inherit two transfer patterns:
1. `transfer(address to, uint256 value)` - A direct transfer.
2. `transferFrom(address from, address to, uint256 value)` - A delegated transfer utilizing the approve-and-transfer workflow.

Since the `NaughtCoin` contract only overrides `transfer()` and did not override or restrict `transferFrom()`, we can use `transferFrom()` to transfer the tokens without triggering the timelock!

---

## 🧠 Attack Strategy

1. **Deploy an Attacker Intermediary**: Deploy `NaughtCoinAttacker` with the address of `NaughtCoin`.
2. **Approve the Attacker**: The player calls the standard `approve(spender, amount)` function on `NaughtCoin`, authorizing `NaughtCoinAttacker` to spend all of their tokens.
   * *Note: The `approve()` function does not have the `lockTokens` modifier applied, so it succeeds immediately.*
3. **Execute standard transferFrom**: Call `attack()` on the attacker contract. Since the attacker contract is the caller (`msg.sender` inside the ERC20 context is the `NaughtCoinAttacker` contract, **not** the player!), it calls `transferFrom(player, attacker, amount)`.
   * *Inside the `transferFrom()` function, the caller is the attacker contract. Thus, the `lockTokens` modifier is bypassed completely, and the transfer succeeds!*

---

## 💻 Solution

### Using Forge Script

```bash
forge script script/15-NaughtCoin.s.sol:NaughtCoinSolution --rpc-url sepolia --broadcast
```

The [script](../../script/15-NaughtCoin.s.sol) deploys the separate [NaughtCoinAttacker.sol](./NaughtCoinAttacker.sol) contract to carry out the approve-and-transfer exploit.

---

## 🛡️ Key Takeaway

- **Ensure exhaustive overrides**: When modifying access controls on inherited libraries or standards (like ERC20, ERC721), ensure that all functions executing state changes (such as both `transfer` and `transferFrom` in ERC20) are exhaustively checked and overridden.
- **Understand dependencies**: Always study the full surface of the contracts you inherit from (like OpenZeppelin's standard ERC20).

---

## 📜 My Transactions

- Attacker Contract Deploy: [0x9f93f5cbb4fdce433473fd4d4f3ddedffa5f9e2bcb5ff2f3444463ecd66485fc](https://sepolia.etherscan.io/tx/0x9f93f5cbb4fdce433473fd4d4f3ddedffa5f9e2bcb5ff2f3444463ecd66485fc)
- Player Approve Spender: [0xc07a8fcc11f3ac4b1eb5a42dbc3801ee90b9c660ed150be5996d31b4e7e72e0b](https://sepolia.etherscan.io/tx/0xc07a8fcc11f3ac4b1eb5a42dbc3801ee90b9c660ed150be5996d31b4e7e72e0b)
- Exploit Transfer Transaction: [0xc61bae374583848251ea801efa4478834c74b77b5f1839ea46213519e59e01fe](https://sepolia.etherscan.io/tx/0xc61bae374583848251ea801efa4478834c74b77b5f1839ea46213519e59e01fe)
