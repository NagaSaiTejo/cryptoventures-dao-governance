// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IVotes} from "../interfaces/IVotes.sol";

/**
 * @title GovernorDelegation
 * @dev Abstract module to handle voting power delegation and snapshotting.
 */
abstract contract GovernorDelegation {
    IVotes public immutable token;

    /**
     * @param _token The address of the GovernanceToken (CVT).
     */
    constructor(IVotes _token) {
        token = _token;
    }

    /**
     * @notice Gets the weighted voting power of an account at a specific timepoint.
     * @dev This calls the GovernanceToken which applies the square-root math.
     * @param account The address to check power for.
     * @param timepoint The block number (snapshot) to check.
     * @return The weighted voting power.
     */
    function getVotes(address account, uint256 timepoint) public view virtual returns (uint256) {
        return token.getWeightedVotingPower(account, timepoint);
    }

    /**
     * @notice Returns the raw stake (token balance) of an account at a specific timepoint.
     * @param account The address to check stake for.
     * @param timepoint The block number (snapshot) to check.
     */
    function getRawStake(address account, uint256 timepoint) public view virtual returns (uint256) {
        return token.getPastVotes(account, timepoint);
    }
}