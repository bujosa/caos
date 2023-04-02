// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library Events {
    /**
     * @dev Emitted when a new employee is registered in the system.
     */
    event EmployeeRegistered(
        string name,
        string hireDate,
        uint256 salary,
        string position,
        address indexed employeeAddress
    );

    /**
     * @dev Emitted when the owner of the contract processes a payment for an employee.
     */
    event PaymentProcessed(
        address indexed employeeAddress,
        uint256 amount,
        uint256 timestamp
    );
}
