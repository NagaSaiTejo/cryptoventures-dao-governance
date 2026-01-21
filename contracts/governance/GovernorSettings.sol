// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {DAOAccessControl} from "../access/DAOAccessControl.sol";
import {IFundPolicy} from "../interfaces/IFundPolicy.sol";

/**
 * @title GovernorSettings
 * @dev Manages global and tier-based governance parameters.
 */
abstract contract GovernorSettings {
    DAOAccessControl public immutable accessControl;
    IFundPolicy public fundPolicy;

    // The delay (in blocks) between when a proposal is created and when voting starts.
    uint256 private _votingDelay;

    event VotingDelaySet(uint256 oldVotingDelay, uint256 newVotingDelay);
    event FundPolicyUpdated(address oldPolicy, address newPolicy);

    /**
     * @param _accessControl Address of the DAOAccessControl contract.
     * @param _fundPolicy Address of the initial FundPolicy contract.
     * @param initialVotingDelay Initial delay before voting begins.
     */
    constructor(
        address _accessControl,
        address _fundPolicy,
        uint256 initialVotingDelay
    ) {
        accessControl = DAOAccessControl(_accessControl);
        fundPolicy = IFundPolicy(_fundPolicy);
        _votingDelay = initialVotingDelay;
    }

    /**
     * @notice Returns the voting delay.
     */
    function votingDelay() public view virtual returns (uint256) {
        return _votingDelay;
    }

    /**
     * @notice Updates the voting delay. 
     * @dev Restricted to the DAO (DEFAULT_ADMIN_ROLE).
     */
    function setVotingDelay(uint256 newVotingDelay) public virtual {
        require(accessControl.hasRole(accessControl.DEFAULT_ADMIN_ROLE(), msg.sender), "GovernorSettings: admin only");
        emit VotingDelaySet(_votingDelay, newVotingDelay);
        _votingDelay = newVotingDelay;
    }

    /**
     * @notice Updates the FundPolicy contract.
     * @dev Restricted to the DAO (DEFAULT_ADMIN_ROLE).
     */
    function setFundPolicy(address newPolicy) public virtual {
        require(accessControl.hasRole(accessControl.DEFAULT_ADMIN_ROLE(), msg.sender), "GovernorSettings: admin only");
        emit FundPolicyUpdated(address(fundPolicy), newPolicy);
        fundPolicy = IFundPolicy(newPolicy);
    }
}