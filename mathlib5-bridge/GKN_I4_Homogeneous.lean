/-
  GKN_I4_Homogeneous.lean — Sledgehammer-closed proof of I4 degree-4 homogeneity.

  Tactics: ring, linarith, norm_num, simp — no Float anywhere.
  Over any CommRing R.

  GKN quartic on the 56-dim E7 rep (diagonal Albert algebra):
    I4(α,β,P,Q) = (αβ − Tr(P·Q))² − 4α·N(Q) − 4β·N(P) + 4·Tr(P# · Q#)
-/
import Mathlib.Tactic

namespace GKN

/-! ## Diagonal Albert algebra over R -/

@[ext]
structure J3 (R : Type*) where
  d1 : R
  d2 : R
  d3 : R

variable {R : Type*} [CommRing R]

def j3Scale (c : R) (X : J3 R) : J3 R :=
  ⟨c * X.d1, c * X.d2, c * X.d3⟩

def j3Tr (X : J3 R) : R :=
  X.d1 + X.d2 + X.d3

def j3Prod (X Y : J3 R) : J3 R :=
  ⟨X.d1 * Y.d1, X.d2 * Y.d2, X.d3 * Y.d3⟩

def j3Norm (X : J3 R) : R :=
  X.d1 * X.d2 * X.d3

-- Freudenthal dual on diagonal Albert: X# = (d2·d3, d1·d3, d1·d2)
def j3Dual (X : J3 R) : J3 R :=
  ⟨X.d2 * X.d3, X.d1 * X.d3, X.d1 * X.d2⟩

/-! ## 56-dim E7 state -/

structure S56 (R : Type*) where
  α : R
  β : R
  P : J3 R
  Q : J3 R

def s56Scale (c : R) (s : S56 R) : S56 R :=
  ⟨c * s.α, c * s.β, j3Scale c s.P, j3Scale c s.Q⟩

def I4 (s : S56 R) : R :=
  let trPQ := j3Tr (j3Prod s.P s.Q)
  let t1   := (s.α * s.β - trPQ) ^ 2
  let t2   := s.α * j3Norm s.Q
  let t3   := s.β * j3Norm s.P
  let t4   := j3Tr (j3Prod (j3Dual s.P) (j3Dual s.Q))
  t1 - 4 * t2 - 4 * t3 + 4 * t4

/-! ## Sub-lemmas: each term is degree 4 under scaling -/

lemma j3Norm_scale (c : R) (X : J3 R) :
    j3Norm (j3Scale c X) = c ^ 3 * j3Norm X := by
  simp only [j3Scale, j3Norm]
  ring

lemma j3Dual_scale (c : R) (X : J3 R) :
    j3Dual (j3Scale c X) = j3Scale (c ^ 2) (j3Dual X) := by
  simp only [j3Scale, j3Dual]
  ext <;> ring

lemma j3Tr_prod_scale (c : R) (X Y : J3 R) :
    j3Tr (j3Prod (j3Scale c X) (j3Scale c Y)) = c ^ 2 * j3Tr (j3Prod X Y) := by
  simp only [j3Scale, j3Prod, j3Tr]
  ring

lemma j3Tr_dual_prod_scale (c : R) (X Y : J3 R) :
    j3Tr (j3Prod (j3Dual (j3Scale c X)) (j3Dual (j3Scale c Y))) =
    c ^ 4 * j3Tr (j3Prod (j3Dual X) (j3Dual Y)) := by
  rw [j3Dual_scale, j3Dual_scale]
  simp only [j3Scale, j3Prod, j3Tr, j3Dual]
  ring

/-! ## Main theorem -/

/-- The GKN quartic invariant I4 is homogeneous of degree 4 over any CommRing. -/
theorem I4_homogeneous (s : S56 R) (c : R) :
    I4 (s56Scale c s) = c ^ 4 * I4 s := by
  simp only [I4, s56Scale]
  rw [j3Tr_prod_scale, j3Norm_scale, j3Norm_scale, j3Tr_dual_prod_scale]
  ring

/-! ## Corollaries -/

/-- Numeric witness: scaling by 2 gives factor 16. -/
theorem I4_scale2 (s : S56 R) : I4 (s56Scale 2 s) = 16 * I4 s := by
  have h := I4_homogeneous s (2 : R); norm_num at h; exact h

theorem I4_zero (s : S56 R) : I4 (s56Scale 0 s) = 0 := by
  have h := I4_homogeneous s (0 : R); simp at h; exact h

end GKN
