# Multi-Tier DAO Treasury Architecture

  ## System Overview
  The **Multi-Tier DAO Treasury** is a decentralized governance framework designed for secure and scalable fund management. It leverages **quadratic (anti-whale) voting** to prevent governance capture and a **tiered fund policy** to apply increasing scrutiny as proposal value grows.

---

## High-Level System Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CryptoVentures DAO Ecosystem                     │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                  ┌────────────────┼────────────────┐
                  │                │                │
            ┌─────▼─────┐   ┌──────▼──────┐   ┌─────▼─────┐
            │Governance │   │ Fund Policy │   │ Treasury  │
            │  Token    │   │  (Tiering)  │   │   Vault   │
            │   (CVT)   │   │             │   │ (Assets)  │
            └─────┬─────┘   └──────┬──────┘   └─────┬─────┘
                  │                │                │
                  └────────┬───────┴────────┬───────┘
                           │                │
                    ┌──────▼──────┐  ┌──────▼──────┐
                    │  Governor   │  │  Timelock   │
                    │   Contract  │  │  Controller │
                    └──────┬──────┘  └──────┬──────┘
                           │                │
                  ┌────────┴────────────────┴───────┐
                  │                                 │
         ┌────────▼──────────┐             ┌────────▼──────────┐
         │  Proposal Flow    │             │  Access Control   │
         │  - Propose        │             │  - Roles (RBAC)   │
         │  - Vote (SQRT)    │             │  - Registry of    │
         │  - Queue/Execute  │             │    Truth          │
         └───────────────────┘             └───────────────────┘
```

---

## Technology Stack

### Smart Contracts
- **Language**: Solidity ^0.8.20
- **Libraries**: OpenZeppelin Contracts v5.5.0  
  - AccessControl  
  - ERC20Votes  
  - TimelockController  
  - SafeERC20  

### Infrastructure & Tooling
- **Framework**: Foundry (Forge, Cast, Anvil)
- **Build Tool**: Forge
- **Testing**: forge-std
- **CI/CD**: GitHub Actions

---

## Application Architecture

```
┌─────────────────────────────────┐
│     Governor (The Brain)        │ Proposal lifecycle & voting
├─────────────────────────────────┤
│    Fund Policy (The Rules)      │ Tiered governance thresholds
├─────────────────────────────────┤
│   Timelock (The Safeguard)      │ Delay & execution enforcement
├─────────────────────────────────┤
│    Vault (The Storage)          │ Asset custody
├─────────────────────────────────┤
│    CVT Token (The Weight)       │ Voting power utility
└─────────────────────────────────┘
```

---

## Core Components

### Governance Modules
- **CryptoVenturesGovernor**  
  Central governance contract managing proposals, voting, queueing, and execution.

- **GovernorCounting**  
  Custom vote-counting logic implementing square-root weighted voting.

- **GovernorDelegation**  
  Handles vote delegation via ERC20Votes-compatible token.

- **GovernorSettings**  
  Stores global parameters including voting delays and FundPolicy reference.

---

### Financial & Access Modules
- **FundPolicy**  
  Defines tier structures with quorum, voting period, maximum amount, and execution delay.

- **TreasuryVault**  
  Secure asset store. Withdrawals restricted to EXECUTOR_ROLE (Timelock).

- **DAOAccessControl**  
  Central role registry defining PROPOSER, EXECUTOR, and CANCELLER roles.

- **VotingPowerMath**  
  Babylonian square-root math library used for quadratic voting.

---

## Data Flows

### Proposal Lifecycle
1. **Creation**  
   `propose()` is called with targets, values, and calldata.  
   FundPolicy assigns a tier based on total requested value.

2. **Pending**  
   Proposal remains pending until votingDelay expires.

3. **Voting**  
   Members call `castVote()`.  
   Voting power = `sqrt(tokenBalance)`.

4. **Conclusion**  
   Quorum check and vote outcome evaluation.

5. **Queueing**  
   Successful proposals are scheduled in the Timelock.

6. **Execution**  
   After tier-defined delay, execution triggers TreasuryVault transfers.

---

## Access Control Logic
- **Default Admin**: Initial deployer (intended to migrate to Timelock)
- **Proposer**: Governor contract
- **Executor**: Timelock contract

DAOAccessControl serves as the system-wide Registry of Truth.

---

## Governance Configuration

### Multi-Tier Spending Rules

| Tier | Range (ETH) | Quorum | Voting Period | Execution Delay |
|-----|-------------|--------|---------------|-----------------|
| 0 – Small Grant | 0–10 | 4% | ~3 days | 1 hour |
| 1 – Mid-Sized | 10–100 | 10% | ~7 days | 1 day |
| 2 – Large Investment | 100+ | 20% | ~14 days | 3 days |

---

## Anti-Whale (Quadratic) Voting

| Stake | Voting Power |
|------|--------------|
| 100 tokens | 10 |
| 10,000 tokens | 100 |

A 100× increase in stake results in only a 10× increase in influence.

---

## Security Considerations
- **Double Voting Prevention**: Enforced per proposal via GovernorCounting
- **Timelock Protection**: All actions require delayed execution
- **Restricted Vault**: No public withdrawals
- **Mandatory Snapshots**: Prevents flash-loan governance attacks
