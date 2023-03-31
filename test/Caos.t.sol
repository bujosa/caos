// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

import "forge-std/Test.sol";
import "../contracts/facets/CaosFacet.sol";

contract CaosTest is Test {
    CaosFacet public caos;

    function setUp() public {
        caos = new CaosFacet();
    }

    function testRegisterEmployee() public {
        caos.registerEmployee("Alice", "2022-01-01", 10000, "Manager");
        (string memory name, string memory position) = caos.getEmployee(
            "Alice"
        );
        assertEq(name, "Alice");
        assertEq(position, "Manager");
    }

    function testLogHoursWorked() public {
        caos.registerEmployee("Alice", "2022-01-01", "10000", "Manager");
        caos.logHoursWorked("Alice", "100");
        uint256 hoursWorked = caos.getHoursWorked("Alice");
        assertEq(hoursWorked, 100);
    }

    function testProcessPayment() public {
        caos.registerEmployee("Alice", "2022-01-01", "10000", "Manager");
        caos.logHoursWorked("Alice", "100");
        caos.processPayment();
        uint256 balance = address(caos).balance;
        assertEq(balance, 10000);
    }
}
