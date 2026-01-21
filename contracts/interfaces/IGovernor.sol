// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
/**
 * @title IGovernor
 * @dev Core interface for proposal management and execution state.
 */
interface IGovernor {
    enum ProposalState { Pending, Active, Canceled, Defeated, Succeeded, Queued, Expired, Executed }

    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) external returns (uint256 proposalId);
    function castVote(uint256 proposalId, uint8 support) external returns (uint256 weight);

    function execute(uint256 proposalId) external payable;

    function state(uint256 proposalId) external view returns (ProposalState);
}