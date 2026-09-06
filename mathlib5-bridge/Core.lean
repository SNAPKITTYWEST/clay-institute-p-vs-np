import Mathlib.Data.Nat.Basic
import Mathlib.Algebra.BigOperators.Basic
import Mathlib.Tactic.Ring
import Mathlib.Data.Finset.Basic

open BigOperators

/-- Sum of squares formula: Σ_{k=0}^{n-1} k^2 = (n-1)n(2n-1)/6 -/
theorem sum_squares_formula (n : ℕ) :
  (∑ k in Finset.range n, k^2 : ℚ) = n * (n - 1) * (2 * n - 1) / 6 := by
  induction n with
  | zero => 
    simp
  | succ n ih =>
    simp [Finset.sum_range_succ, ih]
    ring
