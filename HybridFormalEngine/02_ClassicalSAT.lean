/-
Copyright 2026 Ahmad Ali Parr + Jessica Westerhoff — CC BY 4.0 (math)
Fingerprint: SDC-Ω-∂-2026-PVSNP

HybridFormalEngine — 02 Classical SAT Foundation
STATUS labels explicit. No quantum speedup claim. P vs NP UNRESOLVED.
-/
import HybridFormalEngine.«01_AxiomaticFoundation»

namespace HybridFormalEngine.ClassicalSAT

open AxiomaticFoundation

-- ============================================================
-- SAT(φ) ↔ ∃ a. Eval(φ,a)=1
-- ============================================================

-- DEFINITION: Literal evaluation under assignment
-- STATUS: DEFINITION
def evalLit (a : Assignment) : Lit → Option BVal
  | .pos v => lookup a v
  | .neg v => (lookup a v).map bNot

-- DEFINITION: Clause evaluation — disjunction, false on empty, none if any unassigned
-- STATUS: DEFINITION
def evalClause (a : Assignment) (c : Clause) : Option BVal :=
  c.foldl (fun acc lit =>
    match acc, evalLit a lit with
    | some .b1, _ => some .b1
    | _, some .b1 => some .b1
    | some .b0, some .b0 => some .b0
    | _, _ => none) (some .b0)  -- empty clause = false

-- Edge: empty CNF (no clauses) = true
-- DEFINITION: CNF evaluation — conjunction
-- STATUS: DEFINITION
def evalCNF (a : Assignment) (φ : CNF) : Option BVal :=
  φ.foldl (fun acc c =>
    match acc, evalClause a c with
    | some .b1, some .b1 => some .b1
    | _, _ => some .b0) (some .b1)

-- DEFINITION: SAT
-- STATUS: DEFINITION
def SAT (φ : CNF) : Prop := ∃ a, evalCNF a φ = some .b1

-- DERIVED LEMMA: Truth-functional semantics of each operator
-- STATUS: DERIVED LEMMA (by case on BVal)
theorem bNot_involutive : ∀ b, bNot (bNot b) = b := by intro b; cases b <;> rfl
theorem bAnd_comm : ∀ a b, bAnd a b = bAnd b a := by intro a b; cases a <;> cases b <;> rfl
theorem bOr_comm  : ∀ a b, bOr a b = bOr b a := by intro a b; cases a <;> cases b <;> rfl

-- THEOREM: 3SAT ⊆ SAT at instance level (every 3-CNF is a CNF)
-- STATUS: THEOREM — PROVED (subtype inclusion)
theorem threeSAT_subset_SAT : ∀ φ, Is3CNF φ → (SAT φ → SAT φ) := fun _ _ h => h

-- More precise: the set of 3-CNF instances injects into CNF instances
-- DEFINITION: 3SAT predicate
-- STATUS: DEFINITION
def ThreeSAT (φ : CNF) : Prop := Is3CNF φ ∧ SAT φ

-- THEOREM: Is3CNF φ → (ThreeSAT φ → SAT φ)
-- STATUS: THEOREM — PROVED
theorem threeSAT_implies_SAT : ∀ φ, ThreeSAT φ → SAT φ := fun _ h => h.2

end HybridFormalEngine.ClassicalSAT
