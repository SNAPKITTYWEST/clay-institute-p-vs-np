/-
Copyright 2026 Ahmad Ali Parr + Jessica Westerhoff
SharedFoundation/CommonSemantics.lean — the boxed chain

  Σ → Σ* → L → M → Run → T → P/NP → ≤p → SAT → 3SAT

All provers implement this file, not independent definitions.
-/
import SharedFoundation.Alphabet
import SharedFoundation.Encoding
import SharedFoundation.Language
import SharedFoundation.Machine
import SharedFoundation.Halting
import SharedFoundation.Runtime
import SharedFoundation.Nondeterminism
import SharedFoundation.Certificates
import SharedFoundation.PinNP
import SharedFoundation.Reduction
import SharedFoundation.Completeness
import SharedFoundation.BooleanFormulas
import SharedFoundation.ThreeSAT

-- Re-export the pipeline as a single structure for conformance testing
structure CommonSemantics (Sigma : Type) where
  alphabet : Alphabet
  language : Language Sigma
  detMachine : DetMachineWithInput Sigma
  halting : HaltingConfig detMachine.toDetMachine
  ndetMachine : NDetMachine
  verifier : Verifier Sigma
  -- P/NP are predicates over languages, left abstract for instantiation
  -- SAT/3SAT are defined over Formula; their language forms use enc from layer 2

def pVsNP_unresolved : PvsNPAnswer := .unresolved

-- Conformance gate: every prover must provide an instance of CommonSemantics Bin
-- with identical hashes for each layer (Spec.md is authoritative).

