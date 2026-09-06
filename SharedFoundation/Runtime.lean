/-
Copyright 2026 Ahmad Ali Parr + Jessica Westerhoff
Shared Foundation Layer 6: Runtime
  T_M(x), n=|x|, poly ∃c,k T_M(x)≤c|x|^k, P
-/
import SharedFoundation.Language
import SharedFoundation.Machine

def TimeBound := Nat → Nat
def polyBound (c k : Nat) : TimeBound := fun n => c * n ^ k
def IsPolyTime (T : Nat → Nat) : Prop := ∃ c k : Nat, ∀ n, T n ≤ c * n ^ k
def inputSize {Sigma : Type} (x : List Sigma) : Nat := x.length

-- P via DecidesInTime predicate (Decides + time bound) — abstract over machine model
def P_Language (Sigma : Type) (DecidesInTime : Language Sigma → (Nat → Nat) → Prop) : Language Sigma → Prop :=
  fun L => ∃ T, IsPolyTime T ∧ DecidesInTime L T

