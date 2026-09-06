# Physics: Wick Rotation & Euclidean Path Integral

## Wick Rotation

Converts real temporal coordinates t into imaginary Euclidean coordinates τ = it, transforming the Minkowski metric signature (- + + +) to the positive-definite Euclidean signature (+ + + +).

| Minkowski Domain | Euclidean Domain |
|---|---|
| Dynamic Circuit Evaluation (t ∈ ℝ) | Static Boundary-Value Optimization (τ ∈ ℝ⁺) |
| Hamiltonian Time Evolution (U(t) = e^{-iHt}) | Partition Function (Z = Tr(e^{-βH})) |
| Oscillatory Trajectories | Asymptotic Convergence to Ground State |

## Euclidean Path Integral

State transition probability across verification manifold M₃:

Z = ∫ Dx exp(-S_E[x])

Eliminates destructive interference, converting algebraic complexity bounds into stable evaluations of a classical partition function.

## Spectral Gap & Ground State Projection

Euclidean projection operator:

P_Euc = lim_{τ→∞} e^{-Hτ} / Tr(e^{-Hτ})

Isolates absolute ground state. Persistent spectral gap (Δ > 0) as n → ∞ confirms complexity class separation.

## Analytic Continuation

t → -iτ maps pseudo-Riemannian Lorentzian metric to positive-definite Riemannian metric.

- Elliptic Regularization: eliminates hyperbolic pathologies
- Measure-Theoretic Compactification: maps unbounded trajectories onto compact manifold
