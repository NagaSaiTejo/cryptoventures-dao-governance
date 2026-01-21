// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
/**
 * @title IVotes
 * @dev Interface for the weighted voting power used by the DAO.
 */
interface IVotes {
    /**
     * @notice Returns the square-root weighted voting power for an account.
     */
    function getWeightedVotingPower(address account, uint256 timepoint) external view returns (uint256);

    /**
     * @notice Returns the raw token balance for an account at a specific block.
     */
    function getPastVotes(address account, uint256 timepoint) external view returns (uint256);

    /**
     * @notice Returns the total supply (or weighted total) at a specific block.
     */
    function getPastTotalWeightedSupply(uint256 timepoint) external view returns (uint256);
}