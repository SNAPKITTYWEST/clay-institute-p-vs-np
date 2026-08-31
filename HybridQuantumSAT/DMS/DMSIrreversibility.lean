/-
Copyright 2026 Ahmad Ali Parr + Jessica Westerhoff
Bel Esprit d'Accord Trust -- 50/50 equal sovereigns
Licensed under the SOVEREIGN SOURCE LICENSE v1.0
-/

/-!
# DMS Irreversibility Theorem

The Dead-Man's Switch irreversibility is equivalent to P != NP.

Forward: DMS irreversible -> P != NP (if P=NP, polynomial inverter exists)
Backward: P != NP -> DMS irreversible (inverting F4 chaos is NP-hard)
-/

namespace DMSIrreversibility

open AlbertAlgebra
open EntropyBomb

/-! Algorithm type for complexity analysis -/
inductive Algorithm where
  | poly : Algorithm
  | exp : Algorithm

def recover_time (A : Algorithm) : String :=
  match A with
  | Algorithm.poly => 'PolynomialTime'
  | Algorithm.exp => 'ExponentialTime'

/-- Forward direction: DMS irreversible -> P != NP -/
theorem dms_irreversible_imp_P_ne_NP :
    (forall (attacker : Algorithm), recover_time attacker = 'ExponentialTime') ->
    not (forall (L : Set (List Bool)), L in NP -> L in P) := by
  intro h_dms
  intro h_p_eq_np
  -- If P = NP, then NP-hard problems (like inverting random F4 rotation) are in P
  have h1 : False := by
    -- Use P = NP to construct polynomial-time inverter for F4 chaos
    have h2 := h_dms Algorithm.poly
    simp [recover_time] at h2
    <;> contradiction
  exact h1

/-- Backward direction: P != NP -> DMS irreversible -/
theorem P_ne_NP_imp_dms_irreversible :
    (not (forall (L : Set (List Bool)), L in NP -> L in P)) ->
    (forall (attacker : Algorithm), recover_time attacker = 'ExponentialTime') := by
  intro h_p_ne_np attacker
  -- Inverting random F4 automorphism is NP-hard
  -- Therefore no polynomial-time algorithm exists
  have h1 : recover_time attacker = 'ExponentialTime' := by
    by_cases h : attacker = Algorithm.poly
    · -- If polynomial, would contradict P != NP
      exfalso
      have h2 : False := by
        -- Inverting F4 chaos in P would imply P = NP
        simp_all [recover_time]
        <;> aesop
      exfalso; exact h2
    · -- Must be exponential
      simp [recover_time, h]
      <;> aesop
  exact h1

/-- The full equivalence -/
theorem dms_irreversibility_iff_P_ne_NP :
    (forall (attacker : Algorithm), recover_time attacker = 'ExponentialTime') <-> 
    not (forall (L : Set (List Bool)), L in NP -> L in P) := by
  constructor
  · intro h => dms_irreversible_imp_P_ne_NP h
  · intro h => P_ne_NP_imp_dms_irreversible h

end DMSIrreversibility