# Phase 1: Turing Machine Definitions

## Deterministic Turing Machine (DTM)

A DTM is a 7-tuple:

M = (Q, Σ, Γ, δ, q₀, q_accept, q_reject)

where:
- Q is a finite, non-empty set of states
- Σ is the input alphabet, with ⊔ ∉ Σ
- Γ is the tape alphabet, with Σ ⊂ Γ and ⊔ ∈ Γ
- δ: (Q \ {q_accept, q_reject}) × Γ → Q × Γ × {L, R} is the partial transition function
- q₀ ∈ Q is the initial state
- q_accept, q_reject ∈ Q are distinct terminal states

## Configuration

A configuration is a triple (q, w, i) representing (state, tape contents, head position).

The one-step successor relation ⊢_M transitions between configurations.

M accepts x ∈ Σ* if there is a finite sequence of configurations from the initial configuration of x reaching a configuration whose state is q_accept.

## Running Time

T_M(x) = length of the shortest accepting computation (or ∞ if M rejects or loops).
