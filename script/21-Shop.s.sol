// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/21-Shop/Shop.sol";
import "../src/21-Shop/ShopAttacker.sol";

/**
 * @title Challenge 21 Solution Script
 * @notice Solution script for Shop challenge
 */
contract ShopSolution is Script {
    // Replace with your instance address from Ethernaut
    address constant INSTANCE = 0x54e86C660Ff6A93f95CF65e49BfeF6bE28a430B1;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        console.log("Solving Challenge 21: Shop");
        console.log("Instance:", INSTANCE);

        // TODO: Implement solution when solving
        ShopAttacker attacker = new ShopAttacker(INSTANCE);
        attacker.attack();
        
        require(Shop(INSTANCE).isSold(), "Item not sold");
        console.log("Final Price:", Shop(INSTANCE).price());
        vm.stopBroadcast();

        console.log("Challenge completed!");
    }
}
