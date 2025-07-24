;; Title: VelocityVault - Advanced Liquid Staking Protocol with Governance Rights
;; Summary: High-performance DeFi infrastructure enabling liquid staking with 
;;          automated yield optimization and democratic protocol governance
;; Description: 
;; VelocityVault revolutionizes DeFi staking by combining institutional-grade 
;; yield generation with community-driven governance. Users can stake STX tokens 
;; to earn competitive yields through our proprietary dynamic reward algorithm 
;; while maintaining full liquidity and voting rights in protocol decisions.
;;
;; Our innovative architecture features intelligent tier-based reward multipliers,
;; time-locked bonus mechanisms, and a robust governance framework that ensures
;; sustainable protocol evolution. Built on Stacks L2 with Bitcoin-level security,
;; VelocityVault serves both retail and institutional participants seeking 
;; maximum capital efficiency in the Bitcoin DeFi ecosystem.

;; TOKEN DEFINITIONS

(define-fungible-token ANALYTICS-TOKEN u0)

;; CONSTANTS & ERROR CODES

(define-constant CONTRACT-OWNER tx-sender)

;; Error Definitions
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-INVALID-PROTOCOL (err u1001))
(define-constant ERR-INVALID-AMOUNT (err u1002))
(define-constant ERR-INSUFFICIENT-STX (err u1003))
(define-constant ERR-COOLDOWN-ACTIVE (err u1004))
(define-constant ERR-NO-STAKE (err u1005))
(define-constant ERR-BELOW-MINIMUM (err u1006))
(define-constant ERR-PAUSED (err u1007))

;; STATE VARIABLES

(define-data-var contract-paused bool false)
(define-data-var emergency-mode bool false)
(define-data-var stx-pool uint u0)
(define-data-var base-reward-rate uint u500) ;; 5% base rate (100 = 1%)
(define-data-var bonus-rate uint u100) ;; 1% bonus for longer staking
(define-data-var minimum-stake uint u1000000) ;; Minimum stake amount
(define-data-var cooldown-period uint u1440) ;; 24 hour cooldown in blocks
(define-data-var proposal-count uint u0)

;; DATA MAPS

(define-map Proposals
  { proposal-id: uint }
  {
    creator: principal,
    description: (string-utf8 256),
    start-block: uint,
    end-block: uint,
    executed: bool,
    votes-for: uint,
    votes-against: uint,
    minimum-votes: uint,
  }
)

(define-map UserPositions
  principal
  {
    total-collateral: uint,
    total-debt: uint,
    health-factor: uint,
    last-updated: uint,
    stx-staked: uint,
    analytics-tokens: uint,
    voting-power: uint,
    tier-level: uint,
    rewards-multiplier: uint,
  }
)

(define-map StakingPositions
  principal
  {
    amount: uint,
    start-block: uint,
    last-claim: uint,
    lock-period: uint,
    cooldown-start: (optional uint),
    accumulated-rewards: uint,
  }
)

(define-map TierLevels
  uint
  {
    minimum-stake: uint,
    reward-multiplier: uint,
    features-enabled: (list 10 bool),
  }
)

;; PUBLIC FUNCTIONS

;; Initialize Protocol Tiers
;; Sets up the three-tier reward system with progressive benefits
(define-public (initialize-contract)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    ;; Bronze Tier - Entry Level
    (map-set TierLevels u1 {
      minimum-stake: u1000000, ;; 1M uSTX
      reward-multiplier: u100, ;; 1x multiplier
      features-enabled: (list true false false false false false false false false false),
    })
    ;; Silver Tier - Enhanced Benefits
    (map-set TierLevels u2 {
      minimum-stake: u5000000, ;; 5M uSTX
      reward-multiplier: u150, ;; 1.5x multiplier
      features-enabled: (list true true true false false false false false false false),
    })
    ;; Gold Tier - Premium Access
    (map-set TierLevels u3 {
      minimum-stake: u10000000, ;; 10M uSTX
      reward-multiplier: u200, ;; 2x multiplier
      features-enabled: (list true true true true true false false false false false),
    })
    (ok true)
  )
)

;; Stake STX Tokens
;; Core staking function with optional time-lock for enhanced rewards
(define-public (stake-stx
    (amount uint)
    (lock-period uint)
  )
  (let ((current-position (default-to {
      total-collateral: u0,
      total-debt: u0,
      health-factor: u0,
      last-updated: u0,
      stx-staked: u0,
      analytics-tokens: u0,
      voting-power: u0,
      tier-level: u0,
      rewards-multiplier: u100,
    }
      (map-get? UserPositions tx-sender)
    )))
    ;; Validation checks
    (asserts! (is-valid-lock-period lock-period) ERR-INVALID-PROTOCOL)
    (asserts! (not (var-get contract-paused)) ERR-PAUSED)
    (asserts! (>= amount (var-get minimum-stake)) ERR-BELOW-MINIMUM)
    ;; Transfer STX to contract
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    ;; Calculate tier and rewards
    (let (
        (new-total-stake (+ (get stx-staked current-position) amount))
        (tier-info (get-tier-info new-total-stake))
        (lock-multiplier (calculate-lock-multiplier lock-period))
      )
      ;; Update staking position
      (map-set StakingPositions tx-sender {
        amount: amount,
        start-block: stacks-block-height,
        last-claim: stacks-block-height,
        lock-period: lock-period,
        cooldown-start: none,
        accumulated-rewards: u0,
      })
      ;; Update user position with new tier
      (map-set UserPositions tx-sender
        (merge current-position {
          stx-staked: new-total-stake,
          tier-level: (get tier-level tier-info),
          rewards-multiplier: (* (get reward-multiplier tier-info) lock-multiplier),
        })
      )
      ;; Update global STX pool
      (var-set stx-pool (+ (var-get stx-pool) amount))
      (ok true)
    )
  )
)

;; Initiate Unstaking Process
;; Begins cooldown period for secure withdrawals
(define-public (initiate-unstake (amount uint))
  (let (
      (staking-position (unwrap! (map-get? StakingPositions tx-sender) ERR-NO-STAKE))
      (current-amount (get amount staking-position))
    )
    (asserts! (>= current-amount amount) ERR-INSUFFICIENT-STX)
    (asserts! (is-none (get cooldown-start staking-position)) ERR-COOLDOWN-ACTIVE)
    ;; Set cooldown period
    (map-set StakingPositions tx-sender
      (merge staking-position { cooldown-start: (some stacks-block-height) })
    )
    (ok true)
  )
)

;; Complete Unstaking Process
;; Finalizes withdrawal after cooldown period expires
(define-public (complete-unstake)
  (let (
      (staking-position (unwrap! (map-get? StakingPositions tx-sender) ERR-NO-STAKE))
      (cooldown-start (unwrap! (get cooldown-start staking-position) ERR-NOT-AUTHORIZED))
    )
    (asserts!
      (>= (- stacks-block-height cooldown-start) (var-get cooldown-period))
      ERR-COOLDOWN-ACTIVE
    )
    ;; Return STX to user
    (try! (as-contract (stx-transfer? (get amount staking-position) tx-sender tx-sender)))
    ;; Clear staking position
    (map-delete StakingPositions tx-sender)
    (ok true)
  )
)

;; Create Governance Proposal
;; Enables community-driven protocol governance
(define-public (create-proposal
    (description (string-utf8 256))
    (voting-period uint)
  )
  (let (
      (user-position (unwrap! (map-get? UserPositions tx-sender) ERR-NOT-AUTHORIZED))
      (proposal-id (+ (var-get proposal-count) u1))
    )
    (asserts! (>= (get voting-power user-position) u1000000) ERR-NOT-AUTHORIZED)
    (asserts! (is-valid-description description) ERR-INVALID-PROTOCOL)
    (asserts! (is-valid-voting-period voting-period) ERR-INVALID-PROTOCOL)
    (map-set Proposals { proposal-id: proposal-id } {
      creator: tx-sender,
      description: description,
      start-block: stacks-block-height,
      end-block: (+ stacks-block-height voting-period),
      executed: false,
      votes-for: u0,
      votes-against: u0,
      minimum-votes: u1000000,
    })
    (var-set proposal-count proposal-id)
    (ok proposal-id)
  )
)

;; Vote on Proposal
;; Democratic voting mechanism with stake-weighted power
(define-public (vote-on-proposal
    (proposal-id uint)
    (vote-for bool)
  )
  (let (
      (proposal (unwrap! (map-get? Proposals { proposal-id: proposal-id })
        ERR-INVALID-PROTOCOL
      ))
      (user-position (unwrap! (map-get? UserPositions tx-sender) ERR-NOT-AUTHORIZED))
      (voting-power (get voting-power user-position))
      (max-proposal-id (var-get proposal-count))
    )
    (asserts! (< stacks-block-height (get end-block proposal)) ERR-NOT-AUTHORIZED)
    (asserts! (and (> proposal-id u0) (<= proposal-id max-proposal-id))
      ERR-INVALID-PROTOCOL
    )
    (map-set Proposals { proposal-id: proposal-id }
      (merge proposal {
        votes-for: (if vote-for
          (+ (get votes-for proposal) voting-power)
          (get votes-for proposal)
        ),
        votes-against: (if vote-for
          (get votes-against proposal)
          (+ (get votes-against proposal) voting-power)
        ),
      })
    )
    (ok true)
  )
)

;; Emergency Controls
;; Administrative functions for protocol security

(define-public (pause-contract)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set contract-paused true)
    (ok true)
  )
)

(define-public (resume-contract)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set contract-paused false)
    (ok true)
  )
)