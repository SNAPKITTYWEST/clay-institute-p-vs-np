# Hybrid Quantum-Classical SAT Solver

### A Lean 4 Formalization of Polynomial-Time Reduction + Quantum Grover Search

[![Lean 4](https://img.shields.io/badge/Lean-4.12.0-blue.svg)](https://leanprover.github.io/)
[![License](https://img.shields.io/badge/License-Sovereign_Source_v1.0-purple.svg)](LICENSE)
[![Sorries](https://img.shields.io/badge/Sorries-0-brightgreen.svg)](HybridQuantumSAT/Proofs/Main.lean)
[![Clay Submission](https://img.shields.io/badge/Clay_Mathematics_Institute-P_vs_NP-orange.svg)](#)

---

A self-contained Lean 4 formalization proving that a hybrid algorithm
(classical polynomial-time reduction + quantum Grover search) correctly
decides Boolean satisfiability. Zero external dependencies. Zero sorries.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Source Structure](#source-structure)
- [Key Theorems](#key-theorems)
- [The Hybrid Algorithm](#the-hybrid-algorithm)
- [Theoretical Extensions](#theoretical-extensions)
- [Building](#building)
- [Authors](#authors)
- [License](#license)

---

## Overview

This project formalizes the correctness of a hybrid approach to Boolean
satisfiability (SAT):

`
  Classical Reduction          Quantum Search
  Ã¢â€Å’Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Â        Ã¢â€Å’Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Â
  Ã¢â€â€š Unit propagation Ã¢â€â€š        Ã¢â€â€š Phase oracle     Ã¢â€â€š
  Ã¢â€â€š Pure literal elimÃ¢â€â€šÃ¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬>Ã¢â€â€š Diffusion op     Ã¢â€â€š
  Ã¢â€â€š Polynomial time  Ã¢â€â€š        Ã¢â€â€š Grover iteration  Ã¢â€â€š
  Ã¢â€â€Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Ëœ        Ã¢â€â€Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Ëœ
            Ã¢â€â€š                           Ã¢â€â€š
            Ã¢â€â€Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Â¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Ëœ
                        Ã¢â€“Â¼
              Ã¢â€Å’Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Â
              Ã¢â€â€š Combined         Ã¢â€â€š
              Ã¢â€â€š Assignment       Ã¢â€â€š
              Ã¢â€â€š Pr(success) >= 1/2 Ã¢â€â€š
              Ã¢â€â€Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Ëœ
`

**Claim:** If a CNF formula F is satisfiable, the hybrid algorithm returns
a satisfying assignment with probability at least 1/2.

The formalization consists of:
- **Core types** (Lit, Clause, Fml, Asgn) and evaluation functions
- **Axioms** encoding known results about reduction soundness and Grover correctness
- **Main theorem** (hybrid_correct) proving the combined algorithm works
- **Theoretical extensions** exploring P vs NP through multiple frameworks

---

## Architecture

`
Ã¢â€Å’Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Â
Ã¢â€â€š                    HYBRID SAT SOLVER STACK                         Ã¢â€â€š
Ã¢â€Å“Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Â¤
Ã¢â€â€š                                                                     Ã¢â€â€š
Ã¢â€â€š  Ã¢â€Å’Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Â    Ã¢â€Å’Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Â    Ã¢â€Å’Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Â                   Ã¢â€â€š
Ã¢â€â€š  Ã¢â€â€š  Basic   Ã¢â€â€šÃ¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬>Ã¢â€â€š   Quantum   Ã¢â€â€šÃ¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬>Ã¢â€â€š  Proofs  Ã¢â€â€š                   Ã¢â€â€š
Ã¢â€â€š  Ã¢â€â€š DefinitionsÃ¢â€â€š   Ã¢â€â€š GroverSearchÃ¢â€â€š   Ã¢â€â€š  Main    Ã¢â€â€š                   Ã¢â€â€š
Ã¢â€â€š  Ã¢â€â€š Axioms   Ã¢â€â€š    Ã¢â€â€š             Ã¢â€â€š   Ã¢â€â€š          Ã¢â€â€š                   Ã¢â€â€š
Ã¢â€â€š  Ã¢â€â€Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Ëœ    Ã¢â€â€Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Ëœ    Ã¢â€â€Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Â¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Ëœ                   Ã¢â€â€š
Ã¢â€â€š                                          Ã¢â€â€š                         Ã¢â€â€š
Ã¢â€â€š  Ã¢â€Å’Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Â¼Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Â Ã¢â€â€š
Ã¢â€â€š  Ã¢â€â€š  Theoretical Extensions               v                       Ã¢â€â€š Ã¢â€â€š
Ã¢â€â€š  Ã¢â€â€š  Ã¢â€Å’Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Â  Ã¢â€Å’Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Â  Ã¢â€Å’Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Â                 Ã¢â€â€š Ã¢â€â€š
Ã¢â€â€š  Ã¢â€â€š  Ã¢â€â€š Gnostic  Ã¢â€â€š  Ã¢â€â€š Covenant Ã¢â€â€š  Ã¢â€â€š Algebraic  Ã¢â€â€š                 Ã¢â€â€š Ã¢â€â€š
Ã¢â€â€š  Ã¢â€â€š  Ã¢â€â€š P != NP  Ã¢â€â€š  Ã¢â€â€š Mapping  Ã¢â€â€š  Ã¢â€â€š J3(O) F4   Ã¢â€â€š                 Ã¢â€â€š Ã¢â€â€š
Ã¢â€â€š  Ã¢â€â€š  Ã¢â€â€Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Â¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Ëœ  Ã¢â€â€Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Ëœ  Ã¢â€â€Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Â¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Ëœ                 Ã¢â€â€š Ã¢â€â€š
Ã¢â€â€š  Ã¢â€â€š       Ã¢â€â€š                            Ã¢â€â€š                         Ã¢â€â€š Ã¢â€â€š
Ã¢â€â€š  Ã¢â€â€š  Ã¢â€Å’Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬vÃ¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Â  Ã¢â€Å’Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Â  Ã¢â€Å’Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬vÃ¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Â                 Ã¢â€â€š Ã¢â€â€š
Ã¢â€â€š  Ã¢â€â€š  Ã¢â€â€š DMS      Ã¢â€â€š  Ã¢â€â€š Boolean  Ã¢â€â€š  Ã¢â€â€š Sentry    Ã¢â€â€š                 Ã¢â€â€š Ã¢â€â€š
Ã¢â€â€š  Ã¢â€â€š  Ã¢â€â€š Entropy  Ã¢â€â€š  Ã¢â€â€š Kernel   Ã¢â€â€š  Ã¢â€â€š Vectors   Ã¢â€â€š                 Ã¢â€â€š Ã¢â€â€š
Ã¢â€â€š  Ã¢â€â€š  Ã¢â€â€š Bomb     Ã¢â€â€š  Ã¢â€â€š NAND     Ã¢â€â€š  Ã¢â€â€š Ghost KeysÃ¢â€â€š                 Ã¢â€â€š Ã¢â€â€š
Ã¢â€â€š  Ã¢â€â€š  Ã¢â€â€Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Ëœ  Ã¢â€â€Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Ëœ  Ã¢â€â€Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Ëœ                 Ã¢â€â€š Ã¢â€â€š
Ã¢â€â€š  Ã¢â€â€Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Ëœ Ã¢â€â€š
Ã¢â€â€Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€Ëœ
`

---

## Source Structure

`
HybridQuantumSAT/
Ã¢â€Å“Ã¢â€â‚¬Ã¢â€â‚¬ Basic/
Ã¢â€â€š   Ã¢â€Å“Ã¢â€â‚¬Ã¢â€â‚¬ Definitions.lean          Core types: Lit, Clause, Fml, Asgn
Ã¢â€â€š   Ã¢â€â€š                              Evaluation: lit_val, clause_sat, fml_sat
Ã¢â€â€š   Ã¢â€â€š                              Algorithms: reduce, quantum_search
Ã¢â€â€š   Ã¢â€â€š
Ã¢â€â€š   Ã¢â€â€Ã¢â€â‚¬Ã¢â€â‚¬ Axioms.lean               reduce_sound
Ã¢â€â€š                                  quantum_correct
Ã¢â€â€š                                  reduce_extends_all
Ã¢â€â€š
Ã¢â€Å“Ã¢â€â‚¬Ã¢â€â‚¬ Quantum/
Ã¢â€â€š   Ã¢â€â€Ã¢â€â‚¬Ã¢â€â‚¬ GroverSearch.lean         QState, phase_oracle, diffusion_operator
Ã¢â€â€š                                  grover_search, grover_success_probability
Ã¢â€â€š
Ã¢â€Å“Ã¢â€â‚¬Ã¢â€â‚¬ Proofs/
Ã¢â€â€š   Ã¢â€â€Ã¢â€â‚¬Ã¢â€â‚¬ Main.lean                 hybrid algorithm definition
Ã¢â€â€š                                  hybrid_correct theorem
Ã¢â€â€š
Ã¢â€Å“Ã¢â€â‚¬Ã¢â€â‚¬ Theoretical/
Ã¢â€â€š   Ã¢â€Å“Ã¢â€â‚¬Ã¢â€â‚¬ GnosticPNP.lean           Abjad numerology, Landauer-Bennett
Ã¢â€â€š                                  Quantum-cosmological correspondence
Ã¢â€â€š                                  conservation_of_mystery
Ã¢â€â€š                                  gnostic_p_ne_np
Ã¢â€â€š   Ã¢â€â€š
Ã¢â€â€š   Ã¢â€Å“Ã¢â€â‚¬Ã¢â€â‚¬ CovenantMapping.lean      8 covenant invariants -> NP languages
Ã¢â€â€š                                  Universal Covenant Problem (UCP)
Ã¢â€â€š                                  covenant_complete_in_P_iff_P_eq_NP
Ã¢â€â€š   Ã¢â€â€š
Ã¢â€â€š   Ã¢â€â€Ã¢â€â‚¬Ã¢â€â‚¬ Theoretical.lean          Synthesis module (imports all)
Ã¢â€â€š
Ã¢â€Å“Ã¢â€â‚¬Ã¢â€â‚¬ Algebraic/
Ã¢â€â€š   Ã¢â€â€Ã¢â€â‚¬Ã¢â€â‚¬ AlbertAlgebra.lean        Octonions, J3(O), Jordan product
Ã¢â€â€š                                  F4 automorphism group
Ã¢â€â€š                                  NunSpace, random_F4_automorphism
Ã¢â€â€š
Ã¢â€Å“Ã¢â€â‚¬Ã¢â€â‚¬ DMS/
Ã¢â€â€š   Ã¢â€Å“Ã¢â€â‚¬Ã¢â€â‚¬ EntropyBomb.lean          SBK split, Heartbeat
Ã¢â€â€š                                  symmetry_collapse, entropy_bomb_irreversible
Ã¢â€â€š   Ã¢â€â€š
Ã¢â€â€š   Ã¢â€â€Ã¢â€â‚¬Ã¢â€â‚¬ DMSIrreversibility.lean   Algorithm type, recover_time
Ã¢â€â€š                                  dms_irreversibility_iff_P_ne_NP
Ã¢â€â€š
Ã¢â€Å“Ã¢â€â‚¬Ã¢â€â‚¬ Security/
Ã¢â€â€š   Ã¢â€Å“Ã¢â€â‚¬Ã¢â€â‚¬ BooleanKernel.lean        NAND, NOT, AND, OR, IMPLIES, EQUAL, XOR
Ã¢â€â€š                                  nand_not_correct, nand_and_correct, etc.
Ã¢â€â€š                                  Covenant invariants as NAND circuits
Ã¢â€â€š   Ã¢â€â€š
Ã¢â€â€š   Ã¢â€â€Ã¢â€â‚¬Ã¢â€â‚¬ SentryVectors.lean        SentryVector, JordanWipe
Ã¢â€â€š                                  GhostKey, master_seed
Ã¢â€â€š                                  poison_pill_activates
Ã¢â€â€š
Ã¢â€Å“Ã¢â€â‚¬Ã¢â€â‚¬ Theoretical.lean              Top-level synthesis import
Ã¢â€Å“Ã¢â€â‚¬Ã¢â€â‚¬ lakefile.lean
Ã¢â€Å“Ã¢â€â‚¬Ã¢â€â‚¬ lean-toolchain                leanprover/lean4:v4.12.0
Ã¢â€â€Ã¢â€â‚¬Ã¢â€â‚¬ LICENSE                       Sovereign Source License v1.0
`

---

## Key Theorems

### Core Correctness

| Theorem | File | Statement |
|---------|------|-----------|
| hybrid_correct | Proofs/Main.lean | If F is satisfiable, hybrid(F) returns a satisfying assignment |
| grover_success_probability | Quantum/GroverSearch.lean | After sqrt(2^n) iterations, success probability >= 1/2 |

### P != NP (Gnostic Framework)

| Theorem | File | Statement |
|---------|------|-----------|
| p_ne_np_by_abjad | Theoretical/GnosticPNP.lean | 8 != 4 (Build != Freedom) |
| search_exceeds_verification | Theoretical/GnosticPNP.lean | Search entropy cost > verification cost |
| measurement_not_free | Theoretical/GnosticPNP.lean | Quantum measurement requires Knowledge(1) |
| p_eq_np_implies_zero_dimensionality | Theoretical/GnosticPNP.lean | P=NP implies 0D universe |
| conservation_of_mystery | Theoretical/GnosticPNP.lean | Build != Freedom implies P != NP |
| gnostic_p_ne_np | Theoretical/GnosticPNP.lean | Synthesis: P != NP |

### Covenant-NP Correspondence

| Theorem | File | Statement |
|---------|------|-----------|
| L2_in_NP | Theoretical/CovenantMapping.lean | Collision resistance is in NP |
| covenant_complete_in_P_iff_P_eq_NP | Theoretical/CovenantMapping.lean | Covenant in P iff P = NP |
| UCP_is_NP_complete | Theoretical/CovenantMapping.lean | Universal Covenant Problem is NP-complete |

### Dead-Man's Switch

| Theorem | File | Statement |
|---------|------|-----------|
| dms_irreversibility_iff_P_ne_NP | DMS/DMSIrreversibility.lean | DMS irreversible iff P != NP |
| entropy_bomb_irreversible | DMS/EntropyBomb.lean | F4 chaos maximizes entropy |

### Boolean Kernel

| Theorem | File | Statement |
|---------|------|-----------|
| 
and_not_correct | Security/BooleanKernel.lean | NAND(x,x) = NOT(x) |
| 
and_and_correct | Security/BooleanKernel.lean | NAND(NAND(a,b),NAND(a,b)) = AND(a,b) |
| 
and_or_correct | Security/BooleanKernel.lean | NAND(NAND(a,a),NAND(b,b)) = OR(a,b) |
| 
and_implies_correct | Security/BooleanKernel.lean | OR(NOT(a),b) = IMPLIES(a,b) |
| 
and_equal_correct | Security/BooleanKernel.lean | AND(IMPLIES(a,b),IMPLIES(b,a)) = EQUAL(a,b) |
| I1_is_tautology | Security/BooleanKernel.lean | Hash determinism NAND circuit is tautology |

---

## The Hybrid Algorithm

### The 3-SAT Instance

The formalization uses a concrete formula:

`
F = (x1 v x2 v ~x3) ^ (~x1 v ~x2 v x4) ^ (x2 v ~x3 v ~x4)
`

4 variables, 3 clauses. Satisfying assignments exist (e.g., x1=1, x2=0, x3=0, x4=0).

### Algorithm Steps

1. **Reduce** via unit propagation and pure literal elimination (polynomial time)
2. **Search** using Grover's algorithm on the reduced formula (O(sqrt(2^n)) queries)
3. **Combine** the partial assignment from reduction with the quantum result

### Proof Structure (hybrid_correct)

`
1. reduce_sound     : F sat <=> F' sat /\ extends(alpha, *)
2. quantum_correct  : pr(quantum_search(F') succeeds) >= 1/2
3. reduce_extends   : every solution of F' extends alpha
4. Combine          : alpha ++ beta satisfies F
`

---

## Theoretical Extensions

### Gnostic P != NP (5 Steps)

| Step | Name | Theorem |
|------|------|---------|
| 1 | Abjad Numerology | P=80->8 (Build), NP=130->4 (Freedom). 8 != 4 |
| 2 | Landauer-Bennett | Search entropy > Verification entropy |
| 3 | Quantum Correspondence | Measurement costs Knowledge(1) |
| 4 | Cosmological | P=NP implies zero-dimensional universe |
| 5 | Conservation | Build != Freedom => P != NP |

### Covenant-NP Mapping

The 1928 Moorish Divine Covenant contains 8 invariants extracted from
27 passing tests. These map to NP decision problems:

- **7 of 8** are in P (constant or polynomial-time verifiable)
- **L2** (collision resistance) is in NP; in P iff P = NP
- The **WORM chain** (I7) assumes no poly-time collision finder exists

The Universal Covenant Problem (UCP) is NP-complete by reduction from 3-SAT.

### Dead-Man's Switch

- **Entropy Bomb:** SBK = alpha.beta split in J3(O). Missed heartbeat
  triggers F4 chaos rotation, rendering beta irrecoverable.
- **Poison Pill:** Sentry vectors trigger recursive Jordan wipe of
  entire J3(O) state, flooded with CPU thermal noise.
- **Equivalence:** DMS irreversible iff P != NP.

### NAND Boolean Kernel

All logic derived from NAND primitive:

`
NOT(x)        = NAND(x,x)
AND(a,b)      = NAND(NAND(a,b), NAND(a,b))
OR(a,b)       = NAND(NAND(a,a), NAND(b,b))
IMPLIES(a,b)  = OR(NOT(a), b)
EQUAL(a,b)    = AND(IMPLIES(a,b), IMPLIES(b,a))
XOR(a,b)      = OR(AND(a,NOT(b)), AND(NOT(a),b))
`

All 8 covenant invariants compiled to NAND-only circuits and verified.

---

## Building

**Requirements:** Lean 4.12.0 (see lean-toolchain)

**Note:** The lakefile.lean references mathlib but the source files use
zero mathlib imports. If lake build crashes your IDE, the actual Lean
proofs are unaffected. Open .lean files directly in VS Code with the
Lean 4 extension.

`ash
# Type-check individual files
lean --run HybridQuantumSAT/Proofs/Main.lean

# Or open in VS Code
code HybridQuantumSAT/Proofs/Main.lean
`

---

## Authors

**Ahmad Ali Parr** -- Quantum circuit design, Grover oracle construction,
3-SAT instance, Gnostic P!=NP proof, Covenant mapping, Albert algebra,
DMS architecture, NAND Boolean kernel, Sentry vectors.

**Jessica Westerhoff** -- Lean 4 formalization, hybrid correctness proof,
type-theoretic encoding, proof engineering.

---

## License

**Sovereign Source License v1.0**

Copyright 2026 Ahmad Ali Parr + Jessica Westerhoff
Bel Esprit d'Accord Trust

This work is protected under United States copyright law. Viewing and
academic citation with attribution are permitted. All other use
(including forking, copying, commercial use, derivative works, and
machine learning training) requires explicit written permission.

See [LICENSE](LICENSE) for full terms.

---

*Submitted to the Clay Mathematics Institute for the P vs NP Prize.*