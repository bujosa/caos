// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library Errors {
    /**
     * @dev Thrown when a function receives an invalid employee as input.
     */
    error InvalidEmployee(address);

    /**
     * @dev Thrown when a function receives an invalid rate as input.
     */
    error InvalidRate(uint);

    /**
     * @dev Thrown when a function receives an invalid position as input.
     */
    error InvalidPosition(string);

    /**
     * @dev Thrown when a function receives an invalid amount as input.
     */
    error InvalidAmount(uint);

    /**
     * @dev Thrown when a function receives an invalid address as input like the 0 address.
     */
    error InvalidAddress(address);

    /**
     * @dev Thrown when a function receives an invalid transfer address as input like the 0 address.
     */
    error InvalidTransferToAddress(address);

    /**
     * @dev Thrown when the user with the provided address does not exist.
     */
    error UserNotFound();

    /**
     * @dev Thrown when sender tries to withdraw 0 from its balance.
     */
    error InsufficientBalance();

    /**
     * @dev Thrown when trying to call a function that should not be called by a user but it is implemented to satisfy an interface.
     */
    error ForbiddenOperation();

    /**
     * @dev Thrown when trying to call a function that should be called only by the owner of the contract.
     */
    error OnlyOwner();
}
