import Lake
open Lake DSL

package HybridQuantumSAT where
  leanOptions := #[⟨`autoImplicit, false⟩]

@[default_target]
lean_lib HybridQuantumSAT where
  srcDir := "."
  roots := #[`HybridQuantumSAT]

lean_lib HybridQuantumSAT.Basic where
  srcDir := "."
  roots := #[`HybridQuantumSAT.Basic]

lean_lib HybridQuantumSAT.Proofs where
  srcDir := "."
  roots := #[`HybridQuantumSAT.Proofs]

lean_lib HybridQuantumSAT.Quantum where
  srcDir := "."
  roots := #[`HybridQuantumSAT.Quantum]

@[test_driver]
lean_exe HybridQuantumSATTest where
  root := `Main
  supportInterpreter := true

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "master"