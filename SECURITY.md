# Security Policy: Multi-Tier DAO Treasury

## Security Architecture

The **Multi-Tier DAO Treasury** follows a **Defense in Depth** strategy, applying multiple independent security layers to protect governance integrity and treasury assets.

---

## 1. Role-Based Access Control (RBAC)

All critical permissions are managed through a centralized **DAOAccessControl** registry.

### Defined Roles
- **PROPOSER_ROLE**  
  Assigned exclusively to the Governor contract to ensure all actions originate from valid governance votes.

- **EXECUTOR_ROLE**  
  Granted to the TreasuryTimelock to authorize execution and vault withdrawals.

- **CANCELLER_ROLE**  
  Intended for a security council or DAO-controlled mechanism to cancel queued proposals if risks are identified.

- **DEFAULT_ADMIN_ROLE**  
  Initially held by the deployer for setup, then transferred to the Timelock to achieve full decentralization.

---

## 2. Treasury Protection

### TreasuryVault Isolation
The TreasuryVault is fully decoupled from governance logic.

- **Restricted Withdrawals**  
  Funds can only be moved by entities holding EXECUTOR_ROLE (Timelock).

- **No Direct Ownership**  
  The vault has no traditional owner and relies solely on DAOAccessControl for authorization.

---

## 3. Governance Security

### Anti-Whale Voting
- Square-root (quadratic) weighting ensures voting power scales sub-linearly with token holdings.

### Snapshot Consistency
- Voting power is calculated from ERC20Votes snapshots taken at proposal start blocks.
- Prevents flash-loan and temporary balance manipulation attacks.

### Double-Voting Prevention
- GovernorCounting enforces a strict one-vote-per-address-per-proposal rule.

---

## 4. Mandatory Timelocks

All approved proposals must pass through the TreasuryTimelock.

- **Tiered Delays**  
  Execution delays scale with proposal value, increasing review time for higher-risk actions.

- **Transparency Window**  
  Queued transactions are publicly visible, enabling intervention via CANCELLER_ROLE if needed.

---

## Security Procedures

### Vulnerability Reporting

Please **do not disclose vulnerabilities publicly**.

1. Contact project maintainers with a detailed report.
2. Include reproduction steps or a proof-of-concept if available.
3. Allow reasonable time for remediation prior to disclosure.

---

## Known Security Assumptions

- **Admin Transition**  
  Maximum security is achieved once DEFAULT_ADMIN_ROLE is fully controlled by the Timelock.

- **Quorum Integrity**  
  Assumes sufficiently decentralized token distribution to prevent quorum manipulation.

---

## Testing Status

Security is continuously validated through automated testing:

- **Lifecycle Tests**  
  Enforce proposal state transitions.

- **Security Tests**  
  Validate anti-whale math, access control, and voting integrity.

- **CI Integration**  
  GitHub Actions run tests on every commit and pull request to prevent regressions.

---

## Disclaimer

This system is provided as-is and has not undergone a formal third-party security audit unless explicitly stated.