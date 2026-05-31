// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/26-DoubleEntryPoint/DetectionBot.sol";
import {IForta} from "../src/26-DoubleEntryPoint/DoubleEntryPoint.sol";

interface IDoubleEntryPoint {
    function forta() external view returns (address);
    function cryptoVault() external view returns (address);
}

/**
 * @title Challenge 26 Solution Script
 * @notice Deploy a DetectionBot to protect the vault from being drained via sweepToken
 */
contract DoubleEntryPointSolution is Script {
    address constant INSTANCE = 0x8B87Cba8BA144B655e2b859cFcfcAA12977aB726;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        IDoubleEntryPoint dep = IDoubleEntryPoint(INSTANCE);
        address fortaAddress = dep.forta();
        address vaultAddress = dep.cryptoVault();

        console.log("Forta:", fortaAddress);
        console.log("Vault:", vaultAddress);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy detection bot that alerts when origSender is the vault
        DetectionBot bot = new DetectionBot(vaultAddress, fortaAddress);

        // Register the bot with Forta
        IForta(fortaAddress).setDetectionBot(address(bot));
        console.log("DetectionBot deployed at:", address(bot));

        vm.stopBroadcast();

        console.log("Challenge 26 completed!");
    }
}
