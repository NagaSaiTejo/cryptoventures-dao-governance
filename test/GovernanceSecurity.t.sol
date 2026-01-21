// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {CryptoVenturesGovernor} from "../contracts/governance/CryptoVenturesGovernor.sol";
import {GovernanceToken} from "../contracts/token/GovernanceToken.sol";
import {DAOAccessControl} from "../contracts/access/DAOAccessControl.sol";
import {TreasuryVault} from "../contracts/treasury/TreasuryVault.sol";
import {VotingPowerMath} from "../contracts/libraries/VotingPowerMath.sol";
import {IGovernor} from "../contracts/interfaces/IGovernor.sol";

contract GovernanceSecurityTest is Test {
    CryptoVenturesGovernor governor;
    GovernanceToken token;
    DAOAccessControl access;
    TreasuryVault vault;
    
    address public admin = makeAddr("admin");
    address public attacker = makeAddr("attacker");

    function setUp() public {
        vm.startPrank(admin);
        access = new DAOAccessControl(admin);
        token = new GovernanceToken();
        vault = new TreasuryVault(address(access));
        vm.stopPrank();
    }

    function testAntiWhaleMechanism() public pure {
        uint256 smallStake = 100 * 10**18;
        uint256 whaleStake = 10000 * 10**18;

        uint256 smallPower = VotingPowerMath.calculatePower(smallStake);
        uint256 whalePower = VotingPowerMath.calculatePower(whaleStake);

        assertEq(whalePower, smallPower * 10);
    }

    function testUnauthorizedWithdrawalFails() public {
        vm.deal(address(vault), 10 ether);
        
        vm.prank(attacker);
        vm.expectRevert("TreasuryVault: caller is not an executor");
        vault.withdraw(address(0), payable(attacker), 10 ether);
    }
}