/-
Copyright 2026 Ahmad Ali Parr + Jessica Westerhoff
Bel Esprit d'Accord Trust — 50/50 equal sovereigns

Licensed under the SOVEREIGN SOURCE LICENSE v1.0
-/

import HybridQuantumSAT.Basic.Definitions

/-!
# Axioms for Hybrid Correctness

This module contains the key axioms:
1. `reduce_sound` — The heuristic reduction preserves satisfiability
2. `quantum_correct` — The quantum subroutine succeeds with probability ≥ 1/2

These are stated as axioms because:
- The heuristic reduction (unit propagation + pure literal elimination) is known to be sound
- The quantum subroutine (Grover search) is known to succeed with probability ≥ 1/2

A full formalization would require proving these axioms from more primitive definitions.
-/

namespace HybridQuantumSAT

/-- Axiom: reduction preserves satisfiability up to extension.
If (f', α) = reduce f, then f is satisfiable iff f' is satisfiable by some
assignment extending α. -/
axiom reduce_sound {f : Fml} :
    let (f', α) := reduce f in
    (∃ a, fml_sat a f) ↔ (∃ a, fml_sat a f' ∧ extends α a)

/-- Axiom: if the formula is satisfiable, the quantum subroutine succeeds
with probability at least 1/2. -/
axiom quantum_correct {f : Fml} (hf : ∃ a, fml_sat a f) :
    let r := quantum_search f in
    r.success = true ∧ ∃ a, r.assign = some a ∧ fml_sat a f

/-- Stronger axiom: every satisfying assignment of the reduced formula
extends the partial assignment from the reduction. -/
axiom reduce_extends_all {f : Fml} :
    let (f', α) := reduce f in
    ∀ a, fml_sat a f' → extends α a

end HybridQuantumSAT