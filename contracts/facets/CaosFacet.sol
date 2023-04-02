// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "../interfaces/ICaos.sol";
import "../libraries/Events.sol";

contract CaosFacet is ICaos {
    // State variables
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
        require(
            msg.sender == owner,
            "Only the contract owner can call this function."
        );
        _;
    }
    modifier isEmployee(address employeeAddress) {
        require(
            bytes(employees[employeeAddress].name).length != 0,
            "Not a registered employee."
        );
        _;
    }

    // Public functions
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

    function getEmployee(
        address employeeAddress
    )
        public
        view
        isEmployee(employeeAddress)
        returns (
            string memory name,
            string memory hireDate,
            uint256 salary,
            string memory position,
            uint256 totalHoursWorked,
            uint256 lastPaidDate
        )
    {
        Employee storage employee = employees[employeeAddress];
        name = employee.name;
        hireDate = employee.hireDate;
        salary = employee.salary;
        position = employee.position;
        totalHoursWorked = employee.totalHoursWorked;
        lastPaidDate = employee.lastPaidDate;
    }

    // This function is used to log hours worked by an employee
    function logHours(uint _hours) public isEmployee(msg.sender) {
        employees[msg.sender].totalHoursWorked += _hours;
    }

    // This function is used to pay an employee
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

    // get payment
    function getPayment(
        address employeeAddress
    ) public view isEmployee(employeeAddress) returns (uint256) {
        return payments[employeeAddress];
    }

    function addRate(string memory position, uint rate) public onlyOwner {
        rates[position] = rate;
    }

    function calculatePayment(
        Employee memory employee
    ) public view isEmployee(employee.employeeAddress) returns (uint256) {
        uint256 hourlyRate = rates[employee.position];
        uint256 totalPayment = hourlyRate * employee.totalHoursWorked;

        return totalPayment;
    }
}
