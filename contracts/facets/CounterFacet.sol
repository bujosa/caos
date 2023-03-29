// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract CounterFacet {
    uint256 public number;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }
}
