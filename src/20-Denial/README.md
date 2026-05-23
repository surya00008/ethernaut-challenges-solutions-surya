# Ethernaut Challenge 20 — Denial

Denial of Service (DoS) attack on a contract withdrawal function by exhausting transaction gas.

Instance address:
```
0xf1E3DBa9Be9489E7D60c1B6D681BDf75D075C77b
```

---

## 🎯 Goal

Deny the contract owner from successfully withdrawing funds from the `Denial` contract.

---

## 🔎 Reading the Contract

The `withdraw()` function performs two balance transfers:
```solidity
    function withdraw() public {
        uint256 amountToSend = address(this).balance / 100;
        // perform a call without checking return
        // The recipient can revert, the owner will still get their share
        partner.call{value: amountToSend}("");
        payable(owner).transfer(amountToSend);
        ...
```

The contract sends 1% to the `partner` using a raw call `partner.call{value: amountToSend}("")`. The developer assumed that because the return value of the call is not checked (`if (result) {}`), even if the partner contract *reverted*, the execution would continue and the owner would still receive their share via `transfer()`.

#### 🛡️ The Flaw: Gas Exhaustion
A raw `call` forwards **all remaining transaction gas** to the recipient's callback. If the recipient contract executes an infinite loop (`while (true) {}`), it will consume all forwarded gas, throwing an `Out of Gas` error. This halts and reverts the entire transaction, including the subsequent owner transfer!

---

## 🧠 Attack Strategy

1. **Deploy an Attacker Intermediary**: Deploy `DenialAttacker.sol`.
2. **Set partner**: Call `setWithdrawPartner` on `Denial`, registering `DenialAttacker` as the partner.
3. **Trigger gas exhaustion on call**: Implement a `receive()` fallback inside `DenialAttacker` that loops infinitely:
   ```solidity
   receive() external payable {
       while (true) {} // Consumes all forwarded gas
   }
   ```
4. When `withdraw()` is called, the raw call to the attacker contract gets stuck in the infinite loop, running out of gas and reverting the withdrawal transaction.

---

## 💻 Solution

### Using Forge Script

```bash
forge script script/20-Denial.s.sol:DenialSolution --rpc-url sepolia --broadcast
```

The [script](../../script/20-Denial.s.sol) deploys the separate [DenialAttacker.sol](./DenialAttacker.sol) contract and registers it as the withdraw partner.

---

## 🛡️ Key Takeaway

- **Gas control is critical**: Raw `.call{value: val}("")` forwards all remaining gas. To prevent gas exhaustion vulnerabilities, cap the forwarded gas if calling external untrusted contracts (e.g., using `partner.call{value: amountToSend, gas: 5000}("")`), or adopt a Pull Payment architecture.
- **Do not rely on call recovery**: Low-level calls do not prevent reverts if the caller runs out of gas completely.

---

## 📜 My Transactions

- Attacker Contract Deploy: [0x9abee50bde855c415a8d4d37dbce82258cfa3f3b2e4749a79e4f45c6b0ec0b12](https://sepolia.etherscan.io/tx/0x9abee50bde855c415a8d4d37dbce82258cfa3f3b2e4749a79e4f45c6b0ec0b12)
- Set Partner Transaction: [0xdc201e54eb567706f48f5400c7186920dda31ee92c9fb019ee152dfe3fcf9aae](https://sepolia.etherscan.io/tx/0xdc201e54eb567706f48f5400c7186920dda31ee92c9fb019ee152dfe3fcf9aae)
