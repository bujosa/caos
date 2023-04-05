// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "../interfaces/ICaos.sol";
import "../libraries/Events.sol";
import "../libraries/Errors.sol";

contract CaosFacet {
    // State variabless
    address public owner;
    mapping(address => Employee) private employees;
    mapping(address => uint) private payments;
    address[] private employeeAddresses;
    mapping(string => uint) public rates;

    // Constructor
    constructor() {
        owner = msg.sender;
    }

    // Modifiers
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert Errors.OnlyOwner();
        }
        _;
    }
    modifier isEmployee(address employeeAddress) {
        if (bytes(employees[employeeAddress].name).length == 0) {
            revert Errors.InvalidEmployee(employeeAddress);
        }
        _;
    }

    /**
     * @dev This function is used to add new employee.
     */
    function registerEmployee(
        string memory name,
        string memory hireDate,
        uint256 salary,
        string memory position,
        address employeeAddress,
        uint256 totalHoursWorked
    ) public onlyOwner {
        require(
            employeeAddress != address(0),
            "Caos: employee address cannot be zero"
        );

        if (bytes(employees[employeeAddress].name).length != 0) {
            revert Errors.EmployeeAlreadyExist(employeeAddress);
        }

        require(rates[position] > 0, "Rate for position does not exist.");

        employees[employeeAddress] = Employee({
            name: name,
            hireDate: hireDate,
            salary: salary,
            position: position,
            totalHoursWorked: totalHoursWorked,
            employeeAddress: employeeAddress,
            lastPaidDate: block.timestamp
        });

        emit Events.EmployeeRegistered(
            name,
            hireDate,
            salary,
            position,
            employeeAddress
        );
    }

    /**
     * @dev This function is used to remove an employee.
     */
    function removeEmployee(address employeeAddress) public onlyOwner {
        require(
            employeeAddress != address(0),
            "Caos: employee address cannot be zero"
        );

        if (bytes(employees[employeeAddress].name).length == 0) {
            revert Errors.InvalidEmployee(employeeAddress);
        }

        delete employees[employeeAddress];
        emit Events.RemoveEmployee(employeeAddress, block.timestamp);
    }

    /**
     * @dev This function is used to get an employee.
     * @param employeeAddress The address of the employee.
     * @return employee The employee object.
     */
    function getEmployee(
        address employeeAddress
    )
        public
        view
        isEmployee(employeeAddress)
        onlyOwner
        returns (Employee memory employee)
    {
        return employees[employeeAddress];
    }

    /**
     * @dev This function is used to log hours for an employee.
     * @param _hours The number of hours worked.
     */
    function logHours(uint _hours) public isEmployee(msg.sender) {
        employees[msg.sender].totalHoursWorked += _hours;
    }

    /**
     * @dev This function is used for the owner of the contract to process a payment for an employee.
     * @param employeeAddress The address of the employee.
     */
    function processPayment(
        address employeeAddress
    ) public onlyOwner isEmployee(employeeAddress) {
        uint256 paymentAmount = calculatePayment(employees[employeeAddress]);
        require(paymentAmount > 0, "No hours worked.");
        require(address(this).balance >= paymentAmount, "Insufficient funds.");
        employees[employeeAddress].lastPaidDate = block.timestamp;
        payable(employeeAddress).transfer(paymentAmount);
        employees[employeeAddress].totalHoursWorked = 0;
        payments[employeeAddress] += paymentAmount;
        emit Events.PaymentProcessed(
            employeeAddress,
            paymentAmount,
            block.timestamp
        );
    }

    /**
     * @dev This function is used to get the payment amount for an employee.
     * @param employeeAddress The address of the employee.
     * @return The payment amount for the employee.
     */
    function getPayment(
        address employeeAddress
    ) public view isEmployee(employeeAddress) onlyOwner returns (uint256) {
        return payments[employeeAddress];
    }

    /**
     * @dev This function is used to add a new rate for a position.
     * @param position The position of the employee.
     * @param rate The rate for the position.
     */
    function addRate(string memory position, uint rate) public onlyOwner {
        rates[position] = rate;
    }

    /**
     * @dev This function is used to get the rate for a position.
     * @param position The position of the employee.
     * @return The rate for the position.
     */
    function getRate(string memory position) public view returns (uint) {
        if (rates[position] == 0) {
            revert Errors.InvalidPosition(position);
        }
        return rates[position];
    }

    /**
     * @dev This function is used to calculate the payment for an employee.
     * @param employee The employee object.
     * @return The total payment for the employee.
     */
    function calculatePayment(
        Employee memory employee
    ) internal view isEmployee(employee.employeeAddress) returns (uint256) {
        uint256 hourlyRate = rates[employee.position];
        uint256 totalPayment = hourlyRate * employee.totalHoursWorked;

        return totalPayment;
    }
}
