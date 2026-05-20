// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/38-UniqueNFT/UniqueNFT.sol";

/**
 * @title Challenge 38 Solution Script
 * @notice Solution script for UniqueNFT challenge
 */
contract UniqueNFTSolution is Script {
    // Replace with your instance address from Ethernaut
    address constant INSTANCE = address(0);

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        console.log("Solving Challenge 38: UniqueNFT");
        console.log("Instance:", INSTANCE);

        // TODO: Implement solution when solving

        vm.stopBroadcast();

        console.log("Challenge completed!");
    }
}
