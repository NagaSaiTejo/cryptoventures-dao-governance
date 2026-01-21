// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";

/**
 * @title TreasuryTimelock
 * @dev This contract acts as the owner of the DAO Treasury. 
 * It enforces a mandatory delay before any passed proposal can be executed.
 */
contract TreasuryTimelock is TimelockController {
    /**
     * @param minDelay Minimum time (in seconds) a proposal must wait after passing before execution.
     * @param proposers Addresses that can queue a proposal (this will be your GovernorContract).
     * @param executors Addresses that can trigger the final execution (can be anyone, or specific roles).
     * @param admin The address that can manage roles (usually the DAO itself).
     */
    constructor(
        uint256 minDelay,
        address[] memory proposers,
        address[] memory executors,
        address admin
    ) TimelockController(minDelay, proposers, executors, admin) {}
}