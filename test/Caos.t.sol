// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/forge-std/src/Test.sol";
import "../contracts/facets/CaosFacet.sol";
import "../contracts/libraries/Errors.sol";

contract CaosTest is Test {
    CaosFacet caos;
    address owner;
    address employee1;

    function setUp() public {
        caos = new CaosFacet();
        owner = msg.sender;

        employee1 = address(0x123);

        caos.addRate("Manager", 30);
        caos.registerEmployee(
            "John Doe",
            "2021-01-01",
            1000,
            "Manager",
            employee1,
            0
        );
    }

    // Test for AddRate method
    function testAddRate() public {
        caos.addRate("Test", 20);
        uint rate = caos.getRate("Test");
        assertEq(rate, 20);
    }

    function testExpectRevertAddRate() public {
        vm.prank(employee1);
        vm.expectRevert(abi.encodeWithSelector(Errors.OnlyOwner.selector));
        caos.addRate("Manager", 20);
    }

    // Test getRate method
    function testGetRate() public {
        uint rate = caos.getRate("Manager");
        assertEq(rate, 30);
    }

    function testExpectRevertGetRate() public {
        string memory expectedPosition = "Test2";
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.InvalidPosition.selector,
                expectedPosition
            )
        );
        caos.getRate(expectedPosition);
    }

    // Test for LogHours Method
    function testLogHours() public {
        vm.prank(employee1);
        caos.logHours(100);

        uint hoursWorked = caos.getEmployee(employee1).totalHoursWorked;
        assertEq(hoursWorked, 100);
    }

    function testExpectRevertLogHours() public {
        address expectedAddress = address(0x1234);
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.InvalidEmployee.selector,
                expectedAddress
            )
        );
        vm.prank(expectedAddress);
        caos.logHours(100);
    }

    // Test getEmployee method
    function testGetEmployee() public {
        Employee memory employee = caos.getEmployee(employee1);
        assertEq(employee.name, "John Doe");
        assertEq(employee.hireDate, "2021-01-01");
        assertEq(employee.salary, 1000);
        assertEq(employee.position, "Manager");
        assertEq(employee.totalHoursWorked, 0);
        assertEq(employee.employeeAddress, employee1);
    }

    function testExpectRevertGetEmployee() public {
        address expectedAddress = address(0x1234);
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.InvalidEmployee.selector,
                expectedAddress
            )
        );
        caos.getEmployee(expectedAddress);
    }

    // Test registerEmployee method
    function testRegisterEmployee() public {
        address employee2 = address(0x12345);
        caos.registerEmployee(
            "John Doe",
            "2021-01-01",
            1000,
            "Manager",
            employee2,
            0
        );
        Employee memory employee = caos.getEmployee(employee2);
        assertEq(employee.name, "John Doe");
        assertEq(employee.hireDate, "2021-01-01");
        assertEq(employee.salary, 1000);
        assertEq(employee.position, "Manager");
        assertEq(employee.totalHoursWorked, 0);
        assertEq(employee.employeeAddress, employee2);
    }

    function testExpectRevertRegisterEmployee() public {
        address employee2 = address(0x12345);
        caos.registerEmployee(
            "John Doe",
            "2021-01-01",
            1000,
            "Manager",
            employee2,
            0
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.EmployeeAlreadyExist.selector,
                employee2
            )
        );
        caos.registerEmployee(
            "John Doe",
            "2021-01-01",
            1000,
            "Manager",
            employee2,
            0
        );
    }

    // Test removeEmployee method
    function testRemoveEmployee() public {
        caos.removeEmployee(employee1);
        vm.expectRevert(
            abi.encodeWithSelector(Errors.InvalidEmployee.selector, employee1)
        );
        caos.getEmployee(employee1);
    }

    function testExpectRevertRemoveEmployee() public {
        address expectedAddress = address(0x1234);
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.InvalidEmployee.selector,
                expectedAddress
            )
        );
        caos.removeEmployee(expectedAddress);
    }

    // Test getPayment method
    function testGetPayment() public {
        vm.prank(employee1);
        caos.logHours(100);
        vm.deal(address(caos), 100000 ether);
        caos.processPayment(employee1);
        uint payment = caos.getPayment(employee1);
        assertEq(payment, 3000);
    }

    function testExpectRevertGetPayment() public {
        address expectedAddress = address(0x1234);
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.InvalidEmployee.selector,
                expectedAddress
            )
        );
        caos.getPayment(expectedAddress);
    }

    // Test processPayment method
    function testProcessPayment() public {
        vm.prank(employee1);
        caos.logHours(100);
        vm.deal(address(caos), 100000 ether);
        caos.processPayment(employee1);
        uint payment = caos.getPayment(employee1);
        assertEq(payment, 3000);
    }

    function testExpectRevertProcessPayment() public {
        address expectedAddress = address(0x1234);
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.InvalidEmployee.selector,
                expectedAddress
            )
        );
        caos.processPayment(expectedAddress);
    }
}
