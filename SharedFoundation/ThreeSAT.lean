/-
Copyright 2026 Ahmad Ali Parr + Jessica Westerhoff
Shared Foundation Layer 13: 3-SAT
  3-CNF C1∧…∧Cm ≤3 literals, 3SAT(φ) iff ∃a eval=1, 3SAT∈NP
-/
import SharedFoundation.Language
import SharedFoundation.Runtime
import SharedFoundation.Reduction
import SharedFoundation.Completeness
import SharedFoundation.BooleanFormulas

def Is3CNF {n : Nat} (phi : Formula n) : Prop :=
  match phi with | .cnf cs => ∀ c ∈ cs, c.length ≤ 3

def ThreeSAT {n : Nat} (phi : Formula n) : Prop :=
  Is3CNF phi ∧ SAT phi

def ThreeSATLanguage (Sigma : Type) (enc : {n : Nat} → Formula n → List Sigma) : Language Sigma :=
  fun x => ∃ (n : Nat) (phi : Formula n), Is3CNF phi ∧ SAT phi ∧ enc phi = x

def threeSAT_in_NP_claim (Sigma : Type) (NP : Language Sigma → Prop) (L3 : Language Sigma) : Prop :=
  NP L3

structure ReductionMachinery (Sigma : Type) (NP : Language Sigma → Prop) where
  SATLang : Language Sigma
  ThreeSATLang : Language Sigma
  sat_in_NP : NP SATLang
  threesat_in_NP : NP ThreeSATLang
  sat_complete : NPComplete NP SATLang
  sat_to_3sat : SATLang ≤p ThreeSATLang
  threesat_complete : NPComplete NP ThreeSATLang

