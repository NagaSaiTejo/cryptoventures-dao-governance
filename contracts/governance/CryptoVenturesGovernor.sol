// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {GovernorSettings} from "./GovernorSettings.sol";
import {GovernorCounting} from "./GovernorCounting.sol";
import {GovernorDelegation} from "./GovernorDelegation.sol";
import {IGovernor} from "../interfaces/IGovernor.sol";
import {ITimelock} from "../interfaces/ITimelock.sol";
import {IFundPolicy} from "../interfaces/IFundPolicy.sol";
import {IVotes} from "../interfaces/IVotes.sol";
import {ITreasuryVault} from "../interfaces/ITreasuryVault.sol";
contract CryptoVenturesGovernor is
    IGovernor,
    GovernorSettings,
    GovernorCounting,
    GovernorDelegation
{
    struct ProposalCore {
        uint256 voteStart;
        uint256 voteEnd;
        uint256 amount;
        bool executed;
        bool canceled;
        bool queued;
    }
    mapping(uint256 => ProposalCore) private _proposals;
    mapping(uint256 => address[]) private _proposalTargets;
    mapping(uint256 => uint256[]) private _proposalValues;
    mapping(uint256 => bytes[]) private _proposalCalldatas;
    mapping(uint256 => bytes32) private _proposalSalts;
    ITimelock public immutable timelock;
    ITreasuryVault public immutable vault;
    constructor(
        address _accessControl,
        address _token,
        address payable _timelock,
        address _fundPolicy,
        address _vault
    )
        GovernorSettings(_accessControl, _fundPolicy, 7200)
        GovernorDelegation(IVotes(_token))
    {
        timelock = ITimelock(_timelock);
        vault = ITreasuryVault(_vault);
    }
    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) external override returns (uint256 proposalId) {
        uint256 totalGovernanceValue = 0;
        for (uint256 i = 0; i < targets.length; i++) {
            totalGovernanceValue += values[i];
            if (targets[i] == address(vault)) {
                bytes4 withdrawSelector = bytes4(keccak256("withdraw(address,address,uint256)"));
                if (bytes4(calldatas[i]) == withdrawSelector) {
                    uint256 amount;
                    bytes memory data = calldatas[i];
                    assembly {
                        amount := mload(add(data, 100))
                    }
                    totalGovernanceValue += amount;
                }
            }
        }
        IFundPolicy.Tier memory tier = fundPolicy.getTierForAmount(totalGovernanceValue);
        proposalId = uint256(keccak256(abi.encode(targets, values, calldatas, keccak256(bytes(description)))));

        ProposalCore storage proposal = _proposals[proposalId];
        require(proposal.voteStart == 0, "Governor: proposal already exists");

        _proposalTargets[proposalId] = targets;
        _proposalValues[proposalId] = values;
        _proposalCalldatas[proposalId] = calldatas;
        _proposalSalts[proposalId] = keccak256(bytes(description));

        uint256 start = block.number + votingDelay();
        _proposals[proposalId] = ProposalCore({
            voteStart: start,
            voteEnd: start + tier.votingPeriod,
            amount: totalGovernanceValue,
            executed: false,
            canceled: false,
            queued: false
        });
        return proposalId;
    }
    function castVote(uint256 proposalId, uint8 support) external override returns (uint256 weight) {
        require(state(proposalId) == ProposalState.Active, "Governor: voting is closed");
        ProposalCore storage proposal = _proposals[proposalId];
        uint256 rawStake = getRawStake(msg.sender, proposal.voteStart);
        require(rawStake > 0, "Governor: only token holders can vote");
        _countVote(proposalId, msg.sender, support, rawStake);
        return rawStake;
    }
    function state(uint256 proposalId) public view override returns (ProposalState) {
        ProposalCore storage proposal = _proposals[proposalId];
        if (proposal.executed) return ProposalState.Executed;
        if (proposal.canceled) return ProposalState.Canceled;
        if (proposal.queued) return ProposalState.Queued;
        if (block.number <= proposal.voteStart) return ProposalState.Pending;
        if (block.number <= proposal.voteEnd) return ProposalState.Active;
        IFundPolicy.Tier memory tier = fundPolicy.getTierForAmount(proposal.amount);
        uint256 totalWeightedSupply = token.getPastTotalWeightedSupply(proposal.voteStart);
        if (_quorumReached(proposalId, totalWeightedSupply, tier.minQuorum) && _voteSucceeded(proposalId)) {
            return ProposalState.Succeeded;
        } else {
            return ProposalState.Defeated;
        }
    }
    function queue(uint256 proposalId) external {
        require(state(proposalId) == ProposalState.Succeeded, "Governor: proposal not successful");
        _proposals[proposalId].queued = true;

        IFundPolicy.Tier memory tier = fundPolicy.getTierForAmount(_proposals[proposalId].amount);
        timelock.schedule(
            _proposalTargets[proposalId][0],
            _proposalValues[proposalId][0],
            _proposalCalldatas[proposalId][0],
            bytes32(0),
            _proposalSalts[proposalId],
            tier.executionDelay
        );
    }
    function execute(uint256 proposalId) external payable override {
        require(state(proposalId) == ProposalState.Queued, "Governor: proposal not queued");
        _proposals[proposalId].executed = true;

        timelock.execute{value: msg.value}(
            _proposalTargets[proposalId][0],
            _proposalValues[proposalId][0],
            _proposalCalldatas[proposalId][0],
            bytes32(0),
            _proposalSalts[proposalId]
        );
    }
}