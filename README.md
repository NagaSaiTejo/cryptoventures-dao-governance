# Multi-Tier DAO Treasury

## Project Overview
The **Multi-Tier DAO Treasury** is a decentralized governance system designed for advanced treasury management. It integrates multi-tier fund policies where quorums and voting periods scale dynamically based on the amount of funds requested. To prevent governance capture by large holders, the system utilizes square-root weighted (anti-whale) voting math.

---

## Table of Contents
- [Features](#features)
- [Technical Stack](#technical-stack)
- [Repository Structure](#repository-structure)
- [Setup and Installation](#setup-and-installation)
- [Usage](#usage)
- [Evaluation and Testing](#evaluation-and-testing)
- [License](#license)

---

## Features
- **Multi-Tier Fund Policy**: Spending rules (minimum quorum, voting period, and execution delay) are dynamically determined by proposal value.
- **Anti-Whale Voting**: Square-root weighted voting power using the Babylonian method ensures fair influence distribution.
- **Role-Based Access Control (RBAC)**: A centralized *Registry of Truth* (`DAOAccessControl`) manages permissions for proposers, executors, and cancellers.
- **Timelock Enforcement**: `TreasuryTimelock` enforces mandatory delays and acts as the vault owner.
- **Decentralized Vault**: Secure asset storage permitting withdrawals only through governance-approved execution.

---

## Technical Stack
- **Language**: Solidity ^0.8.20
- **Framework**: Foundry
- **Libraries**: OpenZeppelin Contracts v5.5.0  
  (AccessControl, ERC20, TimelockController)

---

## Repository Structure
```
contracts/
├─ access/        # Role-based access control management
├─ funds/         # Multi-tier policy implementation
├─ governance/    # Governor logic, counting & delegation modules
├─ interfaces/    # Standardized system interfaces
├─ libraries/     # Internal math utilities for quadratic voting
├─ token/         # Governance token with snapshot & weighted voting
├─ treasury/      # Vault and Timelock infrastructure

scripts/          # Deployment and orchestration scripts
test/             # Comprehensive lifecycle & security test suites
```

---

## Setup and Installation

### Prerequisites
- Foundry installed

### Installation
Clone the repository and install dependencies:

```sh
forge install
```

---

## Usage

### Compilation
Build smart contracts and generate artifacts:

```sh
forge build
```

### Testing
Run the full test suite with verbose output:

```sh
forge test -vvv
```

### Deployment
Deploy the complete DAO ecosystem:

```sh
forge script scripts/Deploy.s.sol:DeployDAO \
  --rpc-url <YOUR_RPC_URL> \
  --private-key <YOUR_PRIVATE_KEY> \
  --broadcast
```
---

## Evaluation and Testing
The project includes automated tests designed to satisfy high-security standards:

- **DAOLifecycleTest**
  - Draft → Active → Succeeded → Queued → Executed

- **GovernanceSecurityTest**
  - Anti-whale voting verification
  - Double-voting prevention
  - Role authorization enforcement

---
## License
This project is released under the MIT License.