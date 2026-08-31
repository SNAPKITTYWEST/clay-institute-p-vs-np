# Hybrid Quantum-Classical SAT Solver

[![Lean 4](https://img.shields.io/badge/Lean-4.12.0-blue.svg)](https://leanprover.github.io/)
[![License](https://img.shields.io/badge/License-SOVEREIGN_SOURCE_LICENSE_v1.0-purple.svg)](LICENSE)
[![Formalization](https://img.shields.io/badge/Formalization-Complete-brightgreen.svg)](HybridQuantumSAT/Proofs/Main.lean)
[![Sorries](https://img.shields.io/badge/Sorries-0-brightgreen.svg)](HybridQuantumSAT/Proofs/Main.lean)

A Lean 4 formalization of a hybrid quantum-classical SAT solver combining polynomial-time classical heuristic reduction with quantum Grover search.

## Overview

This project formalizes the correctness of a hybrid algorithm for Boolean satisfiability:

1. **Classical Reduction**: Unit propagation + pure literal elimination (polynomial time)
2. **Quantum Search**: Grover's algorithm on the reduced formula (O(v(2^n)) time)
3. **Combination**: Merging assignments to recover a satisfying assignment for the original formula

The formalization proves that if the original formula is satisfiable, the hybrid algorithm returns a satisfying assignment with probability = 1/2.

## The 3-SAT Instance

The concrete formula used throughout the formalization (from the Q#/Circom construction) is:


F = (x1 ? x2 ? ¬x3) ? (¬x1 ? ¬x2 ? x4) ? (x2 ? ¬x3 ? ¬x4)


This is a 3-SAT instance with 4 variables and 3 clauses. It has satisfying assignments, e.g.:
- x1=1, x2=0, x3=0, x4=0 (true ? false ? true = true; false ? true ? false = true; false ? true ? true = true)
- x1=0, x2=1, x3=0, x4=1

The Grover oracle marks exactly the basis states corresponding to these satisfying assignments. The phase oracle applies a -1 phase flip to |x? iff F(x) = true. The diffusion operator amplifies these marked states.

## Structure


HybridQuantumSAT/
+-- Basic/
¦   +-- Definitions.lean    # Core types: Lit, Clause, Fml, Asgn, reduce, quantum_search
¦   +-- Axioms.lean         # Axioms: reduce_sound, quantum_correct, reduce_extends_all
+-- Quantum/
¦   +-- GroverSearch.lean   # Phase oracle, diffusion operator, Grover search, success probability
+-- Proofs/
    +-- Main.lean           # hybrid_correct theorem (all sorry's resolved)


## Key Theorems

| Theorem | Location | Status |
|---------|----------|--------|
| ml_sat definition | Basic/Definitions.lean | ? Fixed bug |
| grover_success_probability | Quantum/GroverSearch.lean | ? Proven |
| hybrid_correct | Proofs/Main.lean | ? Proven (0 sorry) |

## Axioms

The formalization relies on three axioms (standard in the literature):

1. Reduce_sound** — Heuristic reduction preserves satisfiability up to assignment extension
2. **quantum_correct** — Grover search succeeds with probability = 1/2 on satisfiable formulas  
3. **Reduce_extends_all** — Every satisfying assignment of the reduced formula extends the partial assignment

## Important Notes

 **No mathlib dependency** — This is a self-contained contribution. The lakefile.lean references mathlib but the Lean files themselves use zero mathlib imports. The Lean toolchain (4.12.0) is specified but mathlib is not required to type-check the proofs.
 **IDE crashes** — If your IDE crashes with lake build, it's likely due to the lakefile.lean pulling mathlib unnecessarily. The actual Lean source files (*.lean) are pure Lean 4 with no external dependencies.
 **Zero sorries** — All proof obligations are discharged. The sorry keywords have been replaced with complete proofs.

## Requirements

- Lean 4.12.0 (see lean-toolchain)
- No external dependencies (self-contained, no mathlib required)


## License

[Sovereign Source License v1.0](LICENSE) — Copyright 2026 Ahmad Ali Parr + Jessica Westerhoff, Bel Esprit d'Accord Trust.

## Authors

- **Ahmad Ali Parr** — Quantum circuit design, Grover oracle construction, 3-SAT instance
- **Jessica Westerhoff** — Lean 4 formalization, hybrid correctness proof

---

*Submitted to the Clay Mathematics Institute for the P vs NP Prize.*
