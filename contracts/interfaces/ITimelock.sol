// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ITimelock
 * @dev Interface for the Timelock controller to schedule and execute actions.
 */
interface ITimelock {
    function schedule(
        address target,
        uint256 value,
        bytes calldata data,
        bytes32 predecessor,
        bytes32 salt,
        uint256 delay
    ) external;

    function execute(
        address target,
        uint256 value,
        bytes calldata data,
        bytes32 predecessor,
        bytes32 salt
    ) external payable;
    function cancel(bytes32 id) external;
}