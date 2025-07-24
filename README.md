# VelocityVault 🚀

> Advanced Liquid Staking Protocol with Governance Rights on Stacks Blockchain

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Stacks](https://img.shields.io/badge/Built%20on-Stacks-orange)](https://stacks.co)
[![Clarity](https://img.shields.io/badge/Language-Clarity-blue)](https://clarity-lang.org)

VelocityVault revolutionizes DeFi staking by combining institutional-grade yield generation with community-driven governance. Built on Stacks L2 with Bitcoin-level security, it serves both retail and institutional participants seeking maximum capital efficiency in the Bitcoin DeFi ecosystem.

## 🌟 Features

### Core Functionality

- **Liquid Staking**: Stake STX tokens while maintaining liquidity
- **Dynamic Rewards**: Proprietary reward algorithm with competitive yields
- **Tier-Based System**: Progressive benefits based on stake amount
- **Time-Lock Bonuses**: Enhanced rewards for longer commitment periods
- **Governance Rights**: Democratic protocol decision-making
- **Emergency Controls**: Robust security mechanisms

### Advanced Features

- **Automated Yield Optimization**: Intelligent reward distribution
- **Health Factor Monitoring**: Risk management for user positions
- **Cooldown Security**: Secure withdrawal mechanisms
- **Voting Power**: Stake-weighted governance participation

## 🏗️ Architecture

```text
┌─────────────────────────────────────────────────────────────┐
│                    VelocityVault Protocol                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐    ┌─────────────────┐                │
│  │  User Interface │    │   Governance    │                │
│  │                 │    │    Module       │                │
│  │ • Stake/Unstake │    │ • Proposals     │                │
│  │ • Claim Rewards │    │ • Voting        │                │
│  │ • View Tiers    │    │ • Execution     │                │
│  └─────────────────┘    └─────────────────┘                │
│           │                       │                         │
│           └───────────┬───────────┘                         │
│                       │                                     │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              Core Staking Engine                        │ │
│  │                                                         │ │
│  │ ┌─────────────┐ ┌─────────────┐ ┌─────────────────────┐ │ │
│  │ │ Tier System │ │ Reward Calc │ │ Position Management │ │ │
│  │ │             │ │             │ │                     │ │ │
│  │ │ • Bronze    │ │ • Base Rate │ │ • User Positions    │ │ │
│  │ │ • Silver    │ │ • Tier Mult │ │ • Staking History   │ │ │
│  │ │ • Gold      │ │ • Lock Mult │ │ • Health Factors    │ │ │
│  │ └─────────────┘ └─────────────┘ └─────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                       │                                     │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                Security Layer                           │ │
│  │                                                         │ │
│  │ • Emergency Pause      • Cooldown Periods              │ │
│  │ • Owner Controls       • Input Validation              │ │
│  │ • Access Management    • Safe Transfers                │ │
│  └─────────────────────────────────────────────────────────┘ │
│                       │                                     │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 Data Storage                            │ │
│  │                                                         │ │
│  │ • User Positions       • Staking History               │ │
│  │ • Tier Configurations  • Governance Proposals          │ │
│  │ • Global State         • Analytics Tokens              │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 💎 Tier System

VelocityVault implements a three-tier system with progressive benefits:

| Tier | Minimum Stake | Reward Multiplier | Features |
|------|---------------|-------------------|----------|
| 🥉 **Bronze** | 1M uSTX | 1.0x | Basic staking, Governance participation |
| 🥈 **Silver** | 5M uSTX | 1.5x | Enhanced rewards, Priority support |
| 🥇 **Gold** | 10M uSTX | 2.0x | Premium features, Maximum yields |

## 🔒 Time-Lock Bonuses

Enhance your rewards with time-locked staking:

- **No Lock**: 1.0x multiplier (instant liquidity)
- **1 Month Lock**: 1.25x multiplier
- **2 Month Lock**: 1.5x multiplier

## 🚀 Quick Start

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Node.js 16+ for testing
- Basic understanding of Stacks and Clarity

### Installation

```bash
# Clone the repository
git clone https://github.com/miltonbaba/velocity-vault.git
cd velocity-vault

# Install dependencies
npm install

# Check contracts
clarinet check

# Run tests
npm test
```

### Contract Deployment

```bash
# Deploy to devnet
clarinet integrate

# Deploy to testnet
clarinet deploy --testnet
```

## 📖 Usage

### Staking STX

```clarity
;; Stake 5M uSTX with 1-month lock period
(contract-call? .velocity-vault stake-stx u5000000 u4320)
```

### Creating Governance Proposals

```clarity
;; Create a proposal (requires 1M+ voting power)
(contract-call? .velocity-vault create-proposal 
  "Increase base reward rate to 6%" 
  u2880)
```

### Voting on Proposals

```clarity
;; Vote in favor of proposal #1
(contract-call? .velocity-vault vote-on-proposal u1 true)
```

### Unstaking Process

```clarity
;; Step 1: Initiate unstaking (starts cooldown)
(contract-call? .velocity-vault initiate-unstake u1000000)

;; Step 2: Complete unstaking (after cooldown period)
(contract-call? .velocity-vault complete-unstake)
```

## 🧪 Testing

Run the comprehensive test suite:

```bash
# Run all tests
npm test

# Run specific test file
npm test -- tests/velocity-vault.test.ts

# Check contract syntax
clarinet check
```

## 📊 Key Functions

### Public Functions

| Function | Description | Parameters |
|----------|-------------|------------|
| `stake-stx` | Stake STX tokens with optional time-lock | `amount`, `lock-period` |
| `initiate-unstake` | Begin withdrawal cooldown | `amount` |
| `complete-unstake` | Finalize withdrawal after cooldown | - |
| `create-proposal` | Create governance proposal | `description`, `voting-period` |
| `vote-on-proposal` | Vote on existing proposal | `proposal-id`, `vote-for` |
| `pause-contract` | Emergency pause (owner only) | - |
| `resume-contract` | Resume operations (owner only) | - |

### Read-Only Functions

| Function | Description | Returns |
|----------|-------------|---------|
| `get-contract-owner` | Get contract owner address | `principal` |
| `get-stx-pool` | Get total STX in pool | `uint` |
| `get-proposal-count` | Get total proposals created | `uint` |

## 🔐 Security Features

- **Multi-layered Validation**: Input sanitization and business logic checks
- **Cooldown Periods**: 24-hour withdrawal delays for security
- **Emergency Controls**: Owner-controlled pause/resume functionality
- **Access Management**: Role-based permissions for critical functions
- **Safe Transfers**: Protected STX transfer mechanisms

## 🏛️ Governance

VelocityVault implements democratic governance where:

- **Voting Power**: Proportional to staked amount
- **Proposal Creation**: Requires minimum 1M voting power
- **Voting Period**: Flexible duration (100-2880 blocks)
- **Execution**: Community-driven protocol evolution

## 🔄 Reward Mechanism

### Base Calculation

```math
Rewards = (Stake × Base Rate × Tier Multiplier × Lock Multiplier × Blocks) / 14,400,000
```

### Variables

- **Base Rate**: 5% annually (adjustable via governance)
- **Tier Multiplier**: 1x - 2x based on stake amount
- **Lock Multiplier**: 1x - 1.5x based on commitment period
- **Blocks**: Time since last claim

## 📈 Analytics

VelocityVault includes analytics token functionality for:

- Performance tracking
- Reward optimization
- Protocol health monitoring
- User behavior analysis

## 🛣️ Roadmap

- [ ] **Phase 1**: Core staking functionality ✅
- [ ] **Phase 2**: Advanced governance features ✅
- [ ] **Phase 3**: Yield optimization algorithms
- [ ] **Phase 4**: Cross-chain integration
- [ ] **Phase 5**: Institutional features
- [ ] **Phase 6**: Mobile application

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Process

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
