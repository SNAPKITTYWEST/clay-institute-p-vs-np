# Phase 1: Polynomial Time & Complexity Classes

## Polynomial Time

M runs in polynomial time if there exists a constant c ≥ 0 such that for every x:

T_M(x) ≤ |x|^c + c

## Class P

P = { L ⊆ Σ* | ∃ poly-time DTM M with L(M) = L }

P = ⋃_{k ∈ ℕ} DTIME(n^k)

## Class NP

A language L is in NP if there exists a polynomial p and a deterministic polynomial-time verifier V such that:

x ∈ L ⟺ ∃ w (|w| ≤ p(|x|) ∧ V(x, w) = 1)

Equivalently, L is decided by a nondeterministic Turing machine that runs in polynomial time on every branch.

## NP-Complete Formalizations

### SAT (Cook-Levin)

Given a boolean formula φ in CNF, determine whether there exists a variable assignment satisfying φ.

- Membership in NP: guess the assignment, evaluate
- NP-hardness: tableau construction encodes accepting computation of any NP machine into CNF

### TSP (Traveling Salesperson)

Given a complete graph G=(V,E) with edge weights w: E → ℝ⁺ and budget B, find a simple cycle visiting every vertex with total weight ≤ B.

- In NP: guess the cycle
- NP-hard: reduction from Hamiltonian Cycle

### Graph 3-Coloring

Given an undirected graph G=(V,E), determine if its vertices can be colored using ≤ 3 colors such that no adjacent vertices share a color.

- In NP: guess the coloring
- NP-hard: reduction from 3-SAT
