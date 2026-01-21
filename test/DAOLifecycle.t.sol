// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {CryptoVenturesGovernor} from "../contracts/governance/CryptoVenturesGovernor.sol";
import {GovernanceToken} from "../contracts/token/GovernanceToken.sol";
import {TreasuryTimelock} from "../contracts/treasury/TreasuryTimelock.sol";
import {TreasuryVault} from "../contracts/treasury/TreasuryVault.sol";
import {DAOAccessControl} from "../contracts/access/DAOAccessControl.sol";
import {FundPolicy} from "../contracts/funds/FundPolicy.sol";
import {IGovernor} from "../contracts/interfaces/IGovernor.sol";

contract DAOLifecycleTest is Test {
    CryptoVenturesGovernor governor;
    GovernanceToken token;
    TreasuryTimelock timelock;
    TreasuryVault vault;
    DAOAccessControl access;
    FundPolicy policy;

    address payable public admin = payable(makeAddr("admin"));
    address payable public voter1 = payable(makeAddr("voter1"));
    address payable public recipient = payable(makeAddr("recipient"));

    function setUp() public {
        vm.startPrank(admin);
        access = new DAOAccessControl(admin);
        token = new GovernanceToken();
        
        address[] memory proposers = new address[](0);
        address[] memory executors = new address[](0);
        timelock = new TreasuryTimelock(1 hours, proposers, executors, admin);
        
        vault = new TreasuryVault(address(access));
        policy = new FundPolicy(address(access));
        
        governor = new CryptoVenturesGovernor(
            address(access),
            address(token),
            payable(address(timelock)),
            address(policy),
            address(vault)
        );

        access.grantRole(access.EXECUTOR_ROLE(), address(timelock));
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(0));
        
        vm.deal(address(vault), 1000 ether);
        // Distribute 50,000 tokens (5% of supply) to meet the 4% quorum requirement
        token.transfer(voter1, 50000 * 10**18);
        vm.stopPrank();

        vm.prank(voter1);
        token.delegate(voter1); 
    }
    /**
     * @notice Tests Requirement: Proposals must go through a complete lifecycle.
     */
    function testCompleteProposalLifecycle() public {
        address[] memory targets = new address[](1);
        targets[0] = address(vault);
        uint256[] memory values = new uint256[](1);
        values[0] = 0; // FIXED: Set to 0 because funds are withdrawn from Vault, not sent from Timelock balance
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = abi.encodeWithSelector(vault.withdraw.selector, address(0), recipient, 5 ether);
        
        string memory description = "Small grant for community tools";
        // 1. Propose
        uint256 proposalId = governor.propose(targets, values, calldatas, description);
        assertEq(uint256(governor.state(proposalId)), uint256(IGovernor.ProposalState.Pending));
        // 2. Voting Delay
        vm.roll(block.number + governor.votingDelay() + 1);
        assertEq(uint256(governor.state(proposalId)), uint256(IGovernor.ProposalState.Active));
        // 3. Cast Vote
        vm.prank(voter1);
        governor.castVote(proposalId, 1);
        // 4. Voting Period
        vm.roll(block.number + 21600 + 1);
        assertEq(uint256(governor.state(proposalId)), uint256(IGovernor.ProposalState.Succeeded));
        // 5. Queue
        governor.queue(proposalId);
        assertEq(uint256(governor.state(proposalId)), uint256(IGovernor.ProposalState.Queued));
        // 6. Execution Delay (Timelock)
        vm.warp(block.timestamp + 3600 + 1);
        // 7. Execute
        uint256 initialRecipientBalance = recipient.balance;
        uint256 initialVaultBalance = vault.getBalance(address(0));
        governor.execute(proposalId);
        // 8. Final Assertions
        assertEq(uint256(governor.state(proposalId)), uint256(IGovernor.ProposalState.Executed));
        assertEq(recipient.balance, initialRecipientBalance + 5 ether);
        assertEq(vault.getBalance(address(0)), initialVaultBalance - 5 ether);
    }
}