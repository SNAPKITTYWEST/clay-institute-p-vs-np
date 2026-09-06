import Lake
open Lake DSL

package AxiomEngine where
  leanOptions := #[⟨`autoImplicit, false⟩]

@[default_target]
lean_lib AxiomEngine where
  srcDir := "axiom-engine"
  roots := #[`All]
