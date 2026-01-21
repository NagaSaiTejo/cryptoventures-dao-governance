// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {VotingPowerMath} from "../libraries/VotingPowerMath.sol";

/**
 * @title GovernorCounting
 * @dev Custom counting module that implements square-root weighted voting and quorum checks.
 */
abstract contract GovernorCounting {
    struct ProposalVote {
        uint256 forVotes;
        uint256 againstVotes;
        uint256 abstainVotes;
        mapping(address => bool) hasVoted;
    }

    mapping(uint256 => ProposalVote) private _proposalVotes;

    event VoteCast(address indexed voter, uint256 proposalId, uint8 support, uint256 weight);

    /**
     * @notice Returns the current vote totals for a proposal.
     */
    function proposalVotes(uint256 proposalId) public view virtual returns (uint256 againstVotes, uint256 forVotes, uint256 abstainVotes) {
        ProposalVote storage proposalVote = _proposalVotes[proposalId];
        return (proposalVote.againstVotes, proposalVote.forVotes, proposalVote.abstainVotes);
    }

    /**
     * @notice Checks if an account has already voted.
     */
    function hasVoted(uint256 proposalId, address account) public view virtual returns (bool) {
        return _proposalVotes[proposalId].hasVoted[account];
    }

    /**
     * @notice Determines if the quorum was reached for a proposal.
     * @dev Compares weighted participation against the required quorum from the FundPolicy.
     */
    function _quorumReached(uint256 proposalId, uint256 totalWeightedSupply, uint256 quorumBps) internal view virtual returns (bool) {
        ProposalVote storage proposalVote = _proposalVotes[proposalId];
        uint256 totalParticipation = proposalVote.forVotes + proposalVote.againstVotes + proposalVote.abstainVotes;
        
        // Calculation: (Total Participation * 10,000) / Total Supply >= Quorum in Basis Points
        return (totalParticipation * 10000) / totalWeightedSupply >= quorumBps;
    }

    /**
     * @notice Determines if the "For" votes outweigh the "Against" votes.
     */
    function _voteSucceeded(uint256 proposalId) internal view virtual returns (bool) {
        ProposalVote storage proposalVote = _proposalVotes[proposalId];
        return proposalVote.forVotes > proposalVote.againstVotes;
    }

    /**
     * @notice Internal function to record a vote using square-root power.
     */
    function _countVote(uint256 proposalId, address account, uint8 support, uint256 weight) internal virtual {
        ProposalVote storage proposalVote = _proposalVotes[proposalId];
        require(!proposalVote.hasVoted[account], "GovernorCounting: vote already cast");
        proposalVote.hasVoted[account] = true;

        uint256 weightedPower = VotingPowerMath.calculatePower(weight);

        if (support == 0) proposalVote.againstVotes += weightedPower;
        else if (support == 1) proposalVote.forVotes += weightedPower;
        else if (support == 2) proposalVote.abstainVotes += weightedPower;
        else revert("GovernorCounting: invalid vote type");

        emit VoteCast(account, proposalId, support, weightedPower);
    }
}