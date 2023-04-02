// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract CaosFacet {
    struct Employee {
        string name;
        string hireDate;
        uint salary;
        string position;
        uint totalHoursWorked;
    }

    mapping(address => Employee) private employees;
    mapping(address => uint) private payments;
    address[] private employeeAddresses;

    event EmployeeRegistered(
        string name,
        string hireDate,
        uint256 salary,
        string position,
        address indexed employeeAddress
    );

    event PaymentProcessed(address indexed employeeAddress, uint256 amount);

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can call this function."
        );
        _; // Continues execution if the modifier code above passed
    }

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
        employees[employeeAddress] = Employee({
            name: name,
            hireDate: hireDate,
            salary: salary,
            position: position,
            totalHoursWorked: totalHoursWorked
        });
        emit EmployeeRegistered(
            name,
            hireDate,
            salary,
            position,
            employeeAddress
        );
    }

    function logHours(uint _hours) public {
        employees[msg.sender].totalHoursWorked += _hours;
    }

    function calculatePayroll() public {
        for (uint i = 0; i < employeeAddresses.length; i++) {
            Employee storage employee = employees[employeeAddresses[i]];
            uint pay = employee.totalHoursWorked * employee.salary;
            payments[employeeAddresses[i]] = pay;
            employee.totalHoursWorked = 0;
        }
    }

    function processPayment() public payable {
        require(payments[msg.sender] > 0, "No payment due.");
        require(msg.value == payments[msg.sender], "Incorrect payment amount.");

        // Transfer Ether to employee
        (bool success, ) = payable(msg.sender).call{value: msg.value}("");
        require(success, "Payment failed.");

        payments[msg.sender] = 0;

        emit PaymentProcessed(msg.sender, msg.value);
    }

    function logTransaction() public {
        // log payment transaction
    }
}
