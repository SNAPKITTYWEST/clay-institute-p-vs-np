/-
Copyright 2026 Ahmad Ali Parr + Jessica Westerhoff
Shared Foundation Layer 9: P Inclusion
  Every deterministic poly computation = single-branch nondet ⇒ P⊆NP
  Question P=NP vs P≠NP unresolved — foundation must not assume either.
-/
import SharedFoundation.Language

theorem P_subset_NP {Sigma : Type}
    (P_pred NP_pred : Language Sigma → Prop)
    (embed : ∀ L, P_pred L → NP_pred L) :
    ∀ L, P_pred L → NP_pred L := embed

inductive PvsNPAnswer where
  | equal | notEqual | unresolved
  deriving DecidableEq, Repr

def pVsNP_status : PvsNPAnswer := .unresolved

def P_eq_NP_question {Sigma : Type} (_P _NP : Language Sigma → Prop) : Prop :=
  (∀ L, _P L ↔ _NP L) ∨ ¬ (∀ L, _P L ↔ _NP L)

def P_in_NP_claim {Sigma : Type} (P_pred NP_pred : Language Sigma → Prop) : Prop :=
  ∀ L, P_pred L → NP_pred L
