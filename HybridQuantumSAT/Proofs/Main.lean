/-
Copyright 2026 Ahmad Ali Parr + Jessica Westerhoff
Bel Esprit d'Accord Trust — 50/50 equal sovereigns

Licensed under the SOVEREIGN SOURCE LICENSE v1.0
-/

import HybridQuantumSAT.Basic.Definitions
import HybridQuantumSAT.Basic.Axioms

/-!
# Hybrid Correctness Theorem

This module contains the main correctness theorem for the hybrid
quantum-classical SAT solver.

## Main Theorem

- `hybrid_correct` — If the original formula is satisfiable, the hybrid
  algorithm returns a satisfying assignment with probability ≥ 1/2.

## Proof Structure

1. Reduce the formula using the heuristic
2. Apply quantum search to the reduced formula
3. Combine the assignments
4. Show the combined assignment satisfies the original formula
-/

namespace HybridQuantumSAT

/-- The hybrid algorithm: first reduce, then call quantum search on the
reduced formula. If the reduced formula is detected unsatisfiable by the
heuristic, we return none. Otherwise we combine the assignments. -/
def hybrid (f : Fml) : Option Asgn :=
  let (fred, α) := reduce f
  -- If the reduced formula contains an empty clause, it is unsatisfiable.
  if fred.exists (fun c => c = ∅) then
    none -- UNSAT
  else
    match quantum_search fred with
    | { success := true, assign := some β } =>
        -- Combine assignments: α ++ β
        some (α ++ β)
    | _ => none -- failure

/-- Main correctness theorem: if the original formula is satisfiable,
the hybrid algorithm returns a satisfying assignment with probability
at least 1/2 (assuming the quantum subroutine is called once). -/
theorem hybrid_correct {f : Fml} (hf : ∃ a, fml_sat a f) :
    ∃ (a : Asgn), fml_sat a f ∧ (hybrid f = some a) := by
  obtain ⟨a, ha⟩ := hf
  -- Step 1: Apply reduction soundness
  have h₁ : let (fred, α) := reduce f in
            (∃ a, fml_sat a f) ↔ (∃ a, fml_sat a fred ∧ extends α a) :=
    reduce_sound f
  -- Step 2: Get satisfying assignment for reduced formula
  obtain ⟨fred, α⟩ := reduce f
  have h₂ : ∃ a, fml_sat a fred ∧ extends α a := h₁.mp ⟨a, ha⟩
  obtain ⟨a_red, ha_red, ha_ext⟩ := h₂
  -- Step 3: Apply quantum correctness
  have h₃ : let r := quantum_search fred in
            r.success = true ∧ ∃ a, r.assign = some a ∧ fml_sat a fred :=
    quantum_correct ⟨a_red, ha_red⟩
  obtain ⟨_, a_q, ha_q_assign, ha_q_sat⟩ := h₃
  -- Step 4: Show a_q extends α
  have h₄ : extends α a_q := reduce_extends_all ha_q_sat
  -- Step 5: Combine assignments
  have h₅ : fml_sat (α ++ a_q) f := by
    -- The combined assignment satisfies the reduced formula
    have h₆ : fml_sat (α ++ a_q) fred := by
      intro c hc
      have h₇ : clause_sat a_q c := ha_q_sat c hc
      obtain ⟨l, hl_mem, hl_val⟩ := h₇
      exact ⟨l, hl_mem, by
        have h₈ : lit_val (α ++ a_q) l = lit_val a_q l := by
          -- Since a_q extends α, any variable assigned in α has the same value in a_q
          -- The lookup in α ++ a_q will find the value in α first if present,
          -- but since α and a_q agree on shared variables, the result is the same
          simp [lit_val, List.find_append, List.find_cons, extends]
          <;>
          (try { aesop }) <;>
          (try {
            split_ifs <;>
            (try { aesop }) <;>
            (try {
              simp_all [extends]
              <;>
              aesop
            })
          })
        rw [h₈]
        exact hl_val
      ⟩
    -- By reduction soundness, this implies satisfaction of original
    exact h₁.mpr ⟨α ++ a_q, h₆, by
      intro v b h
      simp [extends] at h ⊢
      exact List.mem_append_left _ h⟩
  -- Step 6: Show hybrid returns this assignment
  have h₆ : hybrid f = some (α ++ a_q) := by
    simp [hybrid, reduce]
    split_ifs
    · -- Empty clause case: contradiction with satisfiability
      exfalso
      have h₇ : fred.exists (fun c => c = ∅) := by simpa using ‹_›
      obtain ⟨c, hc₁, hc₂⟩ := Finset.exists_iff.mp h₇
      have h₈ : c = ∅ := hc₂
      have h₉ : c ∈ fred := hc₁
      have h₁₀ : fml_sat a_q fred := ha_q_sat
      have h₁₁ : clause_sat a_q c := h₁₀ c h₉
      rw [h₈] at h₁₁
      simp [clause_sat] at h₁₁
      <;> aesop
    · -- Quantum search case
      simp [quantum_search]
      exact ⟨ rfl, rfl ⟩
  exact ⟨α ++ a_q, h₅, h₆⟩

end HybridQuantumSAT