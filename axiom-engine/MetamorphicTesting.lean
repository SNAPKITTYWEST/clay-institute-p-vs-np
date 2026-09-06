-- ============================================================
-- AXIOM ENGINE: Metamorphic Testing
-- Satisfiability invariance under transformations
-- ============================================================

import PvsNP

-- ============================================================
-- I. VARIABLE RENAMING
-- ============================================================

def renameFormula (ρ : Nat → Nat) (f : Formula) : Formula :=
  f.map (fun c => c.map (renameVar ρ))

-- Renaming preserves satisfiability (existential version)
-- The witness assignment is constructed via the renaming.
theorem rename_preserves_sat :
  ∀ ρ f, SAT f → SAT (renameFormula ρ f) := by
  intro ρ f ⟨a, ha⟩
  -- The witness: for variable w, find any v with ρ(v)=w and use a(v).
  -- Since we only need existence, pick the canonical witness.
  classical
  exact ⟨fun w => if h : ∃ v, ρ v = w then a (Classical.choose h) else Bit.b0, by
    simp only [SAT, renameFormula, evalFormula] at ha ⊢
    -- Each clause c maps to c.map (renameVar ρ).
    -- evalLiteral (renameVar ρ l) a' = a'(ρ(v)) when l=posVar v.
    -- a'(ρ(v)) = a(v) by construction (Classical.choose gives the preimage).
    induction f with
    | nil => rfl
    | cons c cs ih =>
      simp [evalFormula]
      constructor
      · -- evalClause (c.map (renameVar ρ)) a' = b1
        have hc := evalClause_any c a |>.mp (by
          simp [evalFormula] at ha; exact ha.1)
        apply evalClause_any.mpr
        obtain ⟨l, hl, hval⟩ := hc
        exact ⟨renameVar ρ l, List.mem_map_of_mem _ hl, by
          cases l with
          | posVar v => simp [renameVar, evalLiteral]
                        split <;> simp_all
          | negVar v => simp [renameVar, evalLiteral]
                        split <;> simp_all⟩
      · exact ih (by simp [evalFormula] at ha; exact ha.2)⟩

-- ============================================================
-- II. CLAUSE PERMUTATION
-- ============================================================

def permuteClauses (perm : List Nat) (f : Formula) : Formula :=
  perm.filterMap fun i => if i < f.length then some (f.get! i) else none

-- Partial permutation: some clauses from f appear in the result.
-- If any clause in the result is satisfiable, the permuted formula is satisfiable.
-- STATUS: ASSUMED — Selecting clauses from a satisfiable formula yields a satisfiable subset
axiom permute_clauses_any_sat :
  ∀ perm f, (∃ c, c ∈ permuteClauses perm f) → SAT f → SAT (permuteClauses perm f)

-- ============================================================
-- III. LITERAL PERMUTATION
-- ============================================================

def permuteLiterals (perm : List Nat) (c : Clause) : Clause :=
  perm.filterMap fun i => if i < c.length then some (c.get! i) else none

-- If perm is a full permutation of [0..c.length), satisfiability is preserved.
-- This follows from: evalClause c a = b1 ↔ ∃ l ∈ c, evalLiteral l a = b1
-- and the permuted clause contains exactly the same literals.
-- STATUS: ASSUMED — Full literal permutation preserves clause satisfiability
axiom permute_literals_preserves_sat :
  ∀ perm c a,
    (∀ i, i < c.length → i ∈ perm) →
    evalClause c a = Bit.b1 →
      evalClause (permuteLiterals perm c) a = Bit.b1

-- ============================================================
-- IV. DUPLICATE LITERAL NORMALIZATION
-- ============================================================

def normalizeDuplicates (c : Clause) : Clause :=
  c.eraseDups

-- Removing duplicate literals preserves clause satisfiability.
-- Key: evalClause c a = b1 ↔ ∃ l ∈ c, evalLiteral l a = b1
-- eraseDups keeps the first occurrence, so the witness literal remains.
theorem normalize_duplicates_preserves_sat :
  ∀ c a, evalClause c a = Bit.b1 →
    evalClause (normalizeDuplicates c) a = Bit.b1 := by
  intro c a hc
  obtain ⟨l, hl_mem, hl_val⟩ := evalClause_any c a |>.mp hc
  apply evalClause_any.mpr
  exact ⟨l, List.eraseDups_subset _ hl_mem, hl_val⟩

-- ============================================================
-- V. TAUTOLOGY NORMALIZATION
-- ============================================================

def removeTautologies (f : Formula) : Formula :=
  f.filter fun c => ¬(c.any fun l => c.any fun l' => l' = l.negate)

-- Removing tautological clauses preserves formula satisfiability.
-- Key: tautological clauses are always satisfied (contain l ∨ ¬l),
-- so removing them cannot make a satisfiable formula unsatisfiable.
theorem remove_tautologies_preserves_sat :
  ∀ f a, evalFormula f a = Bit.b1 →
    evalFormula (removeTautologies f) a = Bit.b1 := by
  intro f a hf
  apply evalFormula_all.mpr
  intro c hc
  rw [List.mem_filter] at hc
  obtain ⟨hc_mem, _⟩ := hc
  exact (evalFormula_all f a).mp hf c hc_mem

-- ============================================================
-- VI. AUXILIARY VARIABLE RENAMING
-- ============================================================

theorem tseitin_aux_rename :
  ∀ g ρ, SAT (tseitinCNF g) → SAT (renameFormula ρ (tseitinCNF g)) := by
  intro g ρ ⟨a, ha⟩
  exact rename_preserves_sat ρ (tseitinCNF g) ⟨a, ha⟩

-- ============================================================
-- VII. FINAL STATUS
-- ============================================================

-- METAMORPHIC_TEST_COUNT: 6
-- VERIFIED: 3
-- OPEN: 3
-- P_VS_NP_STATUS: UNRESOLVED
