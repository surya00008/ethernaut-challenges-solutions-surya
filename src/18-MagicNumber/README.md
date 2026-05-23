# Ethernaut Challenge 18 — Magic Number

Deploy a smart contract that returns 42 in under 10 bytes of runtime bytecode.

Instance address:
```
0x35b11055d5A6aeFE2291F402CFD065C98DF20152
```

---

## 🎯 Goal

Build and deploy a "solver" smart contract that returns `42` (`0x2a` in hex) when called, with a runtime bytecode size of **at most 10 bytes**.

---

## 🔎 Reading the Contract

Standard Solidity contracts contain significant compilation overhead (metadata, dispatch logs, function signatures) that compiles to hundreds of bytes. To stay under the strict 10-byte limit, we must write the contract directly in raw EVM bytecode!

Any contract deployment transaction contains two distinct bytecodes:
1. **Initialization Bytecode**: Runs during the `CREATE` execution to set up storage and returns the *runtime bytecode*.
2. **Runtime Bytecode**: The actual code saved at the contract address that runs on every transaction.

---

## 🧠 Bytecode Construction Strategy

### 1. Designing the Runtime Bytecode (to return 42)
To return `42`, we must store it in memory first, and then execute the `RETURN` opcode.

Opcode sequence:
1. `PUSH1 0x2a` (`60 2a`): Push `42` onto stack.
2. `PUSH1 0x00` (`60 00`): Push memory offset `0`.
3. `MSTORE` (`52`): Store value `42` at memory slot `0`.
4. `PUSH1 0x20` (`60 20`): Push output size (32 bytes).
5. `PUSH1 0x00` (`60 00`): Push memory offset `0`.
6. `RETURN` (`f3`): Return 32 bytes from memory starting at offset `0`.

**Runtime Bytecode**: `602a60005260206000f3` (exactly **10 bytes**!).

### 2. Designing the Initialization Bytecode
The initialization bytecode copies our 10-byte runtime bytecode from the transaction data into memory using `CODECOPY` and returns it.

Opcode sequence:
1. `PUSH1 0x0a` (`60 0a`): Size of runtime bytecode (10 bytes).
2. `PUSH1 0x0c` (`60 0c`): Offset of runtime bytecode inside deployment code (12 bytes from start).
3. `PUSH1 0x00` (`60 00`): Destination memory offset `0`.
4. `CODECOPY` (`39`): Copy runtime code to memory starting at offset `0`.
5. `PUSH1 0x0a` (`60 0a`): Size of runtime bytecode.
6. `PUSH1 0x00` (`60 00`): Memory offset `0`.
7. `RETURN` (`f3`): Return runtime code from memory.

**Initialization Bytecode**: `600a600c600039600a6000f3` (exactly **12 bytes**!).

### Combined Deployment Code
`600a600c600039600a6000f3602a60005260206000f3`

---

## 💻 Solution

### Using Forge Script

```bash
forge script script/18-MagicNumber.s.sol:MagicNumberSolution --rpc-url sepolia --broadcast
```

The [script](../../script/18-MagicNumber.s.sol) uses `assembly { create(...) }` to deploy the raw bytecode, then calls `setSolver` on the target contract. No separate attacker contract is needed.

---

## 🛡️ Key Takeaway

- **Understand EVM opcodes**: Knowing how the EVM executes bytecode at the lowest level gives deep insight into contract efficiency, memory access, and compiler overhead.
- **Initialization vs Runtime**: Deploying contracts involves two distinct phases and bytecodes; understanding this lifecycle allows for the creation of customized deployment architectures.

---

## 📜 My Transactions

- Solver Contract Deploy: [0xbe47ac9395ecc8a394da02d7fd6f1e05d000ce5d1e490570a4a64ef3e036458c](https://sepolia.etherscan.io/tx/0xbe47ac9395ecc8a394da02d7fd6f1e05d000ce5d1e490570a4a64ef3e036458c)
- Set Solver Transaction: [0xd4202d410c15fb7c81a6f0702360265d2499d4f9401031dad23237f463687716](https://sepolia.etherscan.io/tx/0xd4202d410c15fb7c81a6f0702360265d2499d4f9401031dad23237f463687716)
