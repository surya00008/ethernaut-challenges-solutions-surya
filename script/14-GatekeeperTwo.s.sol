// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/14-GatekeeperTwo/GatekeeperTwoAttacker.sol";

/**
 * @title Challenge 14 Solution Script
 * @notice Deploy GatekeeperTwoAttacker (key computed in constructor when extcodesize == 0)
 */
contract GatekeeperTwoSolution is Script {
    // Replace with your instance address from Ethernaut
    address constant INSTANCE = 0xF632aa98D257815699Aa66C5c95f8b3592Ee222f;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // The constructor computes the key using XOR and calls enter()
        // During construction, extcodesize(caller) == 0, passing gateTwo
        GatekeeperTwoAttacker attacker = new GatekeeperTwoAttacker(INSTANCE);
        console.log("GatekeeperTwoAttacker deployed at:", address(attacker));

        vm.stopBroadcast();

        console.log("Challenge 14 completed!");
    }
}
