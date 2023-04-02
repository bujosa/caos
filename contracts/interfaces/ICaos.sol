// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

interface ICaos {
    /**
     * @dev This function is used to register a new employee
     */
    function registerEmployee(
        string memory name,
        string memory hireDate,
        uint256 salary,
        string memory position,
        address employeeAddress,
        uint256 totalHoursWorked
    ) external;

    /**
     * @dev This function is used to get an employee
     */
    function getEmployee(
        address employeeAddress
    )
        external
        view
        returns (
            string memory name,
            string memory hireDate,
            uint256 salary,
            string memory position,
            uint256 totalHoursWorked,
            uint256 lastPaidDate
        );

    /**
     * @dev This function is used to log hours for an employee
     */
    function logHours(uint256 _hours) external;

    /**
     * @dev This function is used to process a payment for an employee
     */
    function processPayment(address employeeAddress) external;

    /**
     * @dev This function is used to get the payment amount for an employee
     */
    function getPayment(
        address employeeAddress
    ) external view returns (uint256);

    /**
     * @dev This function is used to add a new position to the positions mapping
     */
    function addRate(string memory position, uint256 rate) external;

    /**
     * @dev This function is used to calculate the payment amount for an employee
     */
    function calculatePayment(
        Employee memory employee
    ) external view returns (uint256);
}

struct Employee {
    string name;
    string hireDate;
    uint256 salary;
    string position;
    uint256 totalHoursWorked;
    address employeeAddress;
    uint256 lastPaidDate;
}
