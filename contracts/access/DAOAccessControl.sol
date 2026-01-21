// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title DAOAccessControl
 * @dev Manages roles and permissions for the CryptoVentures DAO ecosystem.
 * This contract acts as the "Registry of Truth" for which addresses or 
 * contracts are authorized to perform specific governance and treasury actions.
 */
contract DAOAccessControl is AccessControl {
    // Role for the Governor contract to propose actions to the Timelock
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
    
    // Role for addresses authorized to trigger the final execution of a proposal
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");
    
    // Role for a security council or the DAO itself to cancel malicious proposals
    bytes32 public constant CANCELLER_ROLE = keccak256("CANCELLER_ROLE");

    /**
     * @notice Initializes the contract with an admin address.
     * @param admin The address granted the default admin role to manage all other roles.
     */
    constructor(address admin) {
        // The admin is initially the deployer, but should eventually be the Timelock
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }

    /**
     * @dev Utility to check if an account has a specific role.
     * Inherited from OpenZeppelin AccessControl.
     */
    // function hasRole(bytes32 role, address account) public view virtual override returns (bool);
}