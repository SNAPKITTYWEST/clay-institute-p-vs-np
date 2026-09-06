/-
Copyright 2026 Ahmad Ali Parr + Jessica Westerhoff — CC BY 4.0
HybridFormalEngine — 07 Classical Verification Path
Verify_SAT(φ,a)=1 ↔ Eval(φ,a)=1 — authoritative predicate, quantum must not override
-/
import HybridFormalEngine.«02_ClassicalSAT»

namespace HybridFormalEngine.VerificationPath

open ClassicalSAT AxiomaticFoundation

-- DEFINITION: Deterministic verifier
-- STATUS: DEFINITION
def Verify_SAT (φ : CNF) (a : Assignment) : BVal :=
  match evalCNF a φ with
  | some .b1 => .b1
  | _ => .b0

-- THEOREM: Verify correctness predicate
-- STATUS: THEOREM — PROVED (by definition unfolding)
theorem verify_correct : ∀ φ a, Verify_SAT φ a = .b1 ↔ evalCNF a φ = some .b1 := by
  intro φ a
  simp [Verify_SAT]
  constructor
  · intro h; cases h' : evalCNF a φ <;> simp_all
  · intro h; rw [h]; rfl

-- DEFINITION: Authoritative — quantum component correctness is subordinate
-- STATUS: DEFINITION (invariant)
def quantum_must_not_override : Prop := ∀ φ a, Verify_SAT φ a = .b1 ↔ evalCNF a φ = some .b1
axiom quantum_subordinate : quantum_must_not_override

end HybridFormalEngine.VerificationPath
