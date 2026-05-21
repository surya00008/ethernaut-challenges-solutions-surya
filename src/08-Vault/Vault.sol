// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Challenge 08 - Vault
 * @notice Contract code will be copied from Ethernaut website
 * @dev Challenge from https://ethernaut.openzeppelin.com/
 */

contract Vault {
    bool public locked;
    bytes32 private password;

    constructor(bytes32 _password) {
        locked = true;
        password = _password;
    }

    function unlock(bytes32 _password) public {
        if (password == _password) {
            locked = false;
        }
    }
}
