/-
Copyright 2026 Ahmad Ali Parr + Jessica Westerhoff
Shared Foundation Layer 7: Nondeterministic Computation
  δ(C)⊆C, computation tree, x∈L iff ∃ accepting path
-/
import SharedFoundation.Language

-- Use `Set C` as `C → Prop` (core Lean, no Std import needed)
abbrev NSet (C : Type) := C → Prop

structure NDetMachine where
  C : Type
  deltaSet : C → NSet C

def IsNDComputation (M : NDetMachine) (trace : List M.C) : Prop :=
  ∀ i (h : i + 1 < trace.length), M.deltaSet trace[i] trace[i+1]

def NDAccepts {M : NDetMachine} (isAccept : M.C → Prop) (trace : List M.C) : Prop :=
  ∃ c ∈ trace, isAccept c

def NDecides {Sigma : Type} (M : NDetMachine) (init : List Sigma → M.C)
    (isAccept : M.C → Prop) (L : Language Sigma) : Prop :=
  ∀ x, L x ↔ ∃ trace : List M.C, trace.head? = some (init x) ∧ IsNDComputation M trace ∧ NDAccepts isAccept trace
