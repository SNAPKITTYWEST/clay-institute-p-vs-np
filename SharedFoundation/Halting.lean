/-
Copyright 2026 Ahmad Ali Parr + Jessica Westerhoff
Shared Foundation Layer 5: Halting
  C_accept, C_reject, M decides L
-/
import SharedFoundation.Machine
import SharedFoundation.Language

structure HaltingConfig (M : DetMachine) where
  isAccept : M.C → Prop
  isReject : M.C → Prop
  disjoint : ∀ c, ¬(isAccept c ∧ isReject c)

inductive Outcome where | accept | reject deriving DecidableEq, Repr

structure Decides {Sigma : Type} (M : DetMachineWithInput Sigma) (L : Language Sigma)
    (halt : HaltingConfig M.toDetMachine) (run : List Sigma → Option Outcome) : Prop where
  terminates : ∀ x, ∃ o, run x = some o
  soundAccept : ∀ x, run x = some .accept → L x
  soundReject : ∀ x, run x = some .reject → ¬ L x
  complete : ∀ x, L x → run x = some .accept
  completeReject : ∀ x, ¬ L x → run x = some .reject

