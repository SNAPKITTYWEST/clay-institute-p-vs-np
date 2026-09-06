/-
Copyright 2026 Ahmad Ali Parr + Jessica Westerhoff
Shared Foundation Layer 8: Certificates (Verifier formulation)
  w∈Σ*, V(x,w), x∈L iff ∃w V(x,w)=1, |w|≤p(|x|), T_V≤q(|x|)
-/
import SharedFoundation.Language
import SharedFoundation.Runtime

structure Verifier (Sigma : Type) where
  verify : List Sigma → List Sigma → Bool
  time : List Sigma → List Sigma → Nat

def NP_via_Verifier (Sigma : Type) : Language Sigma → Prop :=
  fun L => ∃ (V : Verifier Sigma) (p : TimeBound), IsPolyTime p ∧
    ∀ x, L x ↔ ∃ w : List Sigma, w.length ≤ p x.length ∧ V.verify x w = true

def certBounded {Sigma : Type} (p : TimeBound) (x w : List Sigma) : Prop :=
  w.length ≤ p x.length

