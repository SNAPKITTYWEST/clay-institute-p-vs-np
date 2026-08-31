import Lake
open Lake DSL

package HybridQuantumSAT where
  leanOptions := #[⟨utoImplicit, false⟩]

@[default_target]
lean_lib HybridQuantumSAT where
  srcDir := \".\"
  roots := #[HybridQuantumSAT, HybridQuantumSAT.Basic, HybridQuantumSAT.Quantum, HybridQuantumSAT.Proofs, HybridQuantumSAT.Theoretical, HybridQuantumSAT.Algebraic, HybridQuantumSAT.DMS, HybridQuantumSAT.Security]

@[test_driver]
lean_exe HybridQuantumSATTest where
  root := \Main
  supportInterpreter := true

require mathlib from git
  \"https://github.com/leanprover-community/mathlib4.git\" @ \"master\"