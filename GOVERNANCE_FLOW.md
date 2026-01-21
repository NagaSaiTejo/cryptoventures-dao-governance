# Governance Flow: Multi-Tier DAO Treasury

This document describes the step-by-step lifecycle of a governance proposal within the **CryptoVentures DAO**, from inception to final execution.

---

## Phase 1: Proposal Inception

The lifecycle begins when an address calls `propose()` on the **CryptoVenturesGovernor** contract.

### Steps
- **Action Ingestion**  
  The proposer supplies arrays of target addresses, ETH values, and function calldata.

- **Value Extraction**  
  The system calculates the `totalGovernanceValue` by:
  - Summing ETH values
  - Inspecting calldata for `TreasuryVault.withdraw()` calls

- **Tier Assignment**  
  The Governor queries the **FundPolicy** contract to determine the appropriate tier (e.g., Small Grant or Large Investment).

- **Parameter Storage**  
  A unique proposal ID is created and tier-specific parameters are locked:
  - `votingPeriod`
  - `minQuorum`
  - `executionDelay`

---

## Phase 2: Voting Mechanics

After creation, the proposal enters a **Pending** state.

### Voting Delay
- Default delay: **7,200 blocks**
- Prevents instant voting and allows proposal review

### Active Voting
- **State Transition**: Pending → Active
- Token holders may call `castVote()`

### Voting Power Calculation
- **Snapshot Logic**  
  Voting power is based on token balances at `voteStart` block.
- **Quadratic Weighting**  
  Raw stake is transformed using square-root math via **VotingPowerMath**.

### Support Types
- `0` – Against  
- `1` – For  
- `2` – Abstain  

---

## Phase 3: Result Calculation

When `voteEnd` is reached, the proposal is finalized.

### Quorum Verification
- **GovernorCounting** checks whether:
  ```
  (weightedParticipation * 10000) / weightedSupply >= minQuorum
  ```

### Success Criteria
A proposal **Succeeds** if:
- Minimum quorum is met
- Weighted **For** votes exceed **Against** votes

### Anti-Whale Consistency
- Quorum denominator uses **weighted total supply** (square-rooted)
- Ensures mathematical alignment with quadratic voting

---

## Phase 4: Timelock & Execution

Successful proposals must pass through the **TreasuryTimelock**.

### Queueing
- `queue()` schedules proposal actions
- Execution delay depends on proposal tier
  - Example: Tier 0 → 1 hour delay

### Cooldown Period
- Proposal remains **Queued**
- Community review window
- Authorized `CANCELLER_ROLE` may cancel if risks are found

### Final Execution
- After delay, `execute()` is called
- Timelock performs authorized calls
  - e.g., `TreasuryVault.withdraw()`

---

## Proposal State Transition Table

| State     | Condition                                   | Next State(s)           |
|-----------|---------------------------------------------|-------------------------|
| Pending   | `block.number <= voteStart`                 | Active                  |
| Active    | `block.number <= voteEnd`                   | Succeeded, Defeated     |
| Succeeded | Quorum met AND For > Against                | Queued                  |
| Defeated  | Quorum not met OR Against ≥ For             | Final                   |
| Queued    | `queue()` successfully called               | Executed, Canceled      |
| Executed  | `execute()` successfully called             | Final                   |
| Canceled  | `cancel()` by authorized role               | Final                   |

---

## Summary

The Multi-Tier DAO governance flow ensures:
- Fair voting via quadratic weighting
- Scalable security via tiered scrutiny
- Mandatory delays for transparency and intervention
- Strict role enforcement through centralized access control
