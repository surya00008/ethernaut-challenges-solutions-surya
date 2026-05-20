// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/35-EllipticToken/EllipticToken.sol";

/**
 * @title Challenge 35 Solution Script
 * @notice Solution script for EllipticToken challenge
 */
contract EllipticTokenSolution is Script {
    // Replace with your instance address from Ethernaut
    address constant INSTANCE = address(0);

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        console.log("Solving Challenge 35: EllipticToken");
        console.log("Instance:", INSTANCE);

        // TODO: Implement solution when solving

        vm.stopBroadcast();

        console.log("Challenge completed!");
    }
}
