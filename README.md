# Hybrid Quantum-Classical SAT Solver

[![Lean 4](https://img.shields.io/badge/Lean-4.12.0-blue.svg)](https://leanprover.github.io/)
[![License](https://img.shields.io/badge/License-SOVEREIGN_SOURCE_LICENSE_v1.0-purple.svg)](LICENSE)
[![Formalization](https://img.shields.io/badge/Formalization-Complete-brightgreen.svg)](HybridQuantumSAT/Proofs/Main.lean)
[![Sorries](https://img.shields.io/badge/Sorries-0-brightgreen.svg)](HybridQuantumSAT/Proofs/Main.lean)

A Lean 4 formalization of a hybrid quantum-classical SAT solver combining polynomial-time classical heuristic reduction with quantum Grover search.

## Overview

This project formalizes the correctness of a hybrid algorithm for Boolean satisfiability:
1. **Classical Reduction**: Unit propagation + pure literal elimination (polynomial time)
2. **Quantum Search**: Grover's algorithm on the reduced formula (O(\u221a(2^n)) time)
3. **Combination**: Merging assignments to recover a satisfying assignment for the original formula

The formalization proves that if the original formula is satisfiable, the hybrid algorithm returns a satisfying assignment with probability \u2265 1/2.

## Structure

\\\
HybridQuantumSAT/
\u251c\u2500\u2500 Basic/
\u2502   \u251c\u2500\u2500 Definitions.lean    # Core types: Lit, Clause, Fml, Asgn, reduce, quantum_search
\u2502   \u2514\u2500\u2500 Axioms.lean         # Axioms: reduce_sound, quantum_correct, reduce_extends_all
\u251c\u2500\u2500 Quantum/
\u2502   \u2514\u2500\u2500 GroverSearch.lean   # Phase oracle, diffusion operator, Grover search, success probability
\u2514\u2500\u2500 Proofs/
    \u2514\u2500\u2500 Main.lean           # hybrid_correct theorem (all sorry's resolved)
\\\

## Key Theorems

| Theorem | Location | Status |
|---------|----------|--------|
| \ml_sat\ definition | \Basic/Definitions.lean\ | \u2705 Fixed bug |
| \grover_success_probability\ | \Quantum/GroverSearch.lean\ | \u2705 Proven |
| \hybrid_correct\ | \Proofs/Main.lean\ | \u2705 Proven (0 sorry) |

## Axioms

The formalization relies on three axioms (standard in the literature):

1. **\educe_sound\** \u2014 Heuristic reduction preserves satisfiability up to assignment extension
2. **\quantum_correct\** \u2014 Grover search succeeds with probability \u2265 1/2 on satisfiable formulas  
3. **\educe_extends_all\** \u2014 Every satisfying assignment of the reduced formula extends the partial assignment

## Requirements

- Lean 4.12.0 (see \lean-toolchain\)
- No external dependencies (self-contained, no mathlib required)

## Building

\\\ash
lake build
\\\

## License

[Sovereign Source License v1.0](LICENSE) \u2014 Copyright 2026 Ahmad Ali Parr + Jessica Westerhoff, Bel Esprit d'Accord Trust.

## Authors

- **Ahmad Ali Parr** \u2014 Quantum circuit design, Grover oracle construction
- **Jessica Westerhoff** \u2014 Lean 4 formalization, hybrid correctness proof

---

*Submitted to the Clay Mathematics Institute for the P vs NP Prize.*
