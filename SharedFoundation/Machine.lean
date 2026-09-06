/-
Copyright 2026 Ahmad Ali Parr + Jessica Westerhoff
Shared Foundation Layer 4: Deterministic Machine
  M, C, δ:C→C (or C→C'), C0→…→Ct with encoded input
-/

-- Deterministic computational machine (abstract, not yet TM-specific)
structure DetMachine where
  C : Type               -- configurations
  delta : C → C          -- deterministic transition
  decEqC : DecidableEq C

-- Relational view δ : C → C' as graph of function
def deltaRel (M : DetMachine) (c c' : M.C) : Prop := M.delta c = c'

-- Computation: finite sequence C0→C1→…→Ct via delta
def IsComputation (M : DetMachine) (trace : List M.C) : Prop :=
  ∀ i : Nat, ∀ h : i + 1 < trace.length,
    M.delta trace[i] = trace[i+1]'h

-- Initial configuration contains encoded input x ∈ Σ*
-- We keep input injection abstract: init : List Sigma → M.C
structure DetMachineWithInput (Sigma : Type) extends DetMachine where
  init : List Sigma → C

-- Helper to index lists with proof (used above)
-- trace[i]'h is valid when h : i < length

