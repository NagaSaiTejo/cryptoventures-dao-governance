// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ITreasuryVault} from "../interfaces/ITreasuryVault.sol";
import {DAOAccessControl} from "../access/DAOAccessControl.sol";

/**
 * @title TreasuryVault
 * @dev Implementation of the DAO's asset storage with role-based access control.
 */
contract TreasuryVault is ITreasuryVault {
    using SafeERC20 for IERC20;

    DAOAccessControl public immutable accessControl;

    /**
     * @param _accessControl The address of the DAOAccessControl contract.
     */
    constructor(address _accessControl) {
        accessControl = DAOAccessControl(_accessControl);
    }

    // Allow the vault to receive ETH
    receive() external payable {
        emit FundsDeposited(address(0), msg.sender, msg.value);
    }

    /**
     * @inheritdoc ITreasuryVault
     * @dev Restricted to the EXECUTOR_ROLE (typically the Timelock).
     */
    function withdraw(address token, address payable to, uint256 amount) external override {
        require(
            accessControl.hasRole(accessControl.EXECUTOR_ROLE(), msg.sender),
            "TreasuryVault: caller is not an executor"
        );

        if (token == address(0)) {
            require(address(this).balance >= amount, "TreasuryVault: insufficient ETH balance");
            (bool success, ) = to.call{value: amount}("");
            require(success, "TreasuryVault: ETH transfer failed");
        } else {
            IERC20(token).safeTransfer(to, amount);
        }

        emit FundsWithdrawn(token, to, amount);
    }

    /**
     * @inheritdoc ITreasuryVault
     */
    function getBalance(address token) external view override returns (uint256) {
        if (token == address(0)) {
            return address(this).balance;
        } else {
            return IERC20(token).balanceOf(address(this));
        }
    }
}