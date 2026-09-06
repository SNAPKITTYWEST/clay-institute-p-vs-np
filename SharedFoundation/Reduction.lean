/-
Copyright 2026 Ahmad Ali Parr + Jessica Westerhoff
Shared Foundation Layer 10: Polynomial Reduction
  A≤p B via poly-time f, x∈A ↔ f(x)∈B
-/
import SharedFoundation.Language
import SharedFoundation.Runtime

structure PolyTimeFun (Sigma : Type) where
  f : List Sigma → List Sigma
  poly : IsPolyTime (fun n => n) -- placeholder: existence of poly bound on time

def PolyReduces {Sigma : Type} (A B : Language Sigma) : Prop :=
  ∃ (_pf : PolyTimeFun Sigma), ∀ x, A x ↔ B (_pf.f x)

notation:50 A " ≤p " B => PolyReduces A B

