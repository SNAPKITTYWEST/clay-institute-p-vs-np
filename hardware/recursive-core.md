# Hardware: Recursive Core

## Lyapunov Function

V(x) = Σ_{j=1}^{m} w_j · φ(C_j, x)

where:
- w_j = weight of clause j
- φ(C_j, x) = 1 if clause j violated, 0 if satisfied

## Convergence

The recursive circuit converges to a fixed point in at most V(x₀) ≤ m steps (number of clauses).

## Local Minimum Trap

For NP-hard instances, energy landscape is "rugged." States exist where V(x_local) > 0 but all neighbors have V(x_adj) > V(x_local).

Resolution: Stochastic Perturbation Module (SPM) with Metropolis-Hastings criterion.

## Acceptance Probability

α(x, x') = min(1, exp(-(V(x') - V(x)) / T))

## Invariants

- Detailed Balance: P_ij · π_i = P_ji · π_j
- Ergodicity: Every state reachable from every other state
