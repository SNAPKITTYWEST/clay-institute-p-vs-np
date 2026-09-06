/-
Copyright 2026 Ahmad Ali Parr + Jessica Westerhoff
Shared Foundation Layer 11: NP-Completeness
  NP-hard: ∀A∈NP A≤p L ; NP-complete: L∈NP ∧ NP-hard
-/
import SharedFoundation.Language
import SharedFoundation.Reduction

def NPHard {Sigma : Type} (NP : Language Sigma → Prop) (L : Language Sigma) : Prop :=
  ∀ A, NP A → PolyReduces A L

def NPComplete {Sigma : Type} (NP : Language Sigma → Prop) (L : Language Sigma) : Prop :=
  NP L ∧ NPHard NP L

theorem complete_hardest {Sigma : Type} {NP : Language Sigma → Prop} {L A : Language Sigma}
    (hL : NPComplete NP L) (hA : NP A) : PolyReduces A L := hL.2 A hA
