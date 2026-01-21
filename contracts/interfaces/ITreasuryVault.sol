// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ITreasuryVault
 * @dev Interface for the CryptoVentures DAO Treasury Vault.
 */
interface ITreasuryVault {
    /**
     * @notice Emitted when funds are withdrawn from the vault.
     */
    event FundsWithdrawn(address indexed token, address indexed to, uint256 amount);

    /**
     * @notice Emitted when funds are deposited into the vault.
     */
    event FundsDeposited(address indexed token, address indexed from, uint256 amount);

    /**
     * @notice Withdraws ETH or ERC20 tokens from the vault to a recipient.
     * @param token The address of the token to withdraw (address(0) for ETH).
     * @param to The recipient address.
     * @param amount The amount to withdraw.
     */
    function withdraw(address token, address payable to, uint256 amount) external;

    /**
     * @notice Returns the balance of a specific token held by the vault.
     * @param token The address of the token (address(0) for ETH).
     */
    function getBalance(address token) external view returns (uint256);
}