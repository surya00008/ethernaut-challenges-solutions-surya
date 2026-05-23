// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";

interface IMagicNum {
    function setSolver(address _solver) external;
}

/**
 * @title Challenge 18 Solution Script
 * @notice Deploy a minimal contract (<=10 opcodes) that returns 42 using raw bytecode
 */
contract MagicNumberSolution is Script {
    // Replace with your instance address from Ethernaut
    address constant INSTANCE = 0x35b11055d5A6aeFE2291F402CFD065C98DF20152;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // Runtime bytecode (10 bytes): returns 42 (0x2a) for any call
        // PUSH1 0x2a  (602a)  - push 42
        // PUSH1 0x00  (6000)  - push memory offset 0
        // MSTORE      (52)    - store 42 at memory[0]
        // PUSH1 0x20  (6020)  - push return size 32
        // PUSH1 0x00  (6000)  - push return offset 0
        // RETURN      (f3)    - return memory[0:32]
        //
        // Init bytecode: copies runtime code to memory and returns it
        // PUSH1 0x0a  (600a)  - runtime code size (10 bytes)
        // PUSH1 0x0c  (600c)  - runtime code offset in this bytecode
        // PUSH1 0x00  (6000)  - memory offset
        // CODECOPY    (39)    - copy code to memory
        // PUSH1 0x0a  (600a)  - runtime code size
        // PUSH1 0x00  (6000)  - memory offset
        // RETURN      (f3)    - return runtime code

        bytes memory bytecode = hex"600a600c600039600a6000f3602a60005260206000f3";

        address solver;
        assembly {
            solver := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        require(solver != address(0), "Failed to deploy solver");
        console.log("Solver deployed at:", solver);

        IMagicNum(INSTANCE).setSolver(solver);

        vm.stopBroadcast();

        console.log("Challenge 18 completed!");
    }
}
