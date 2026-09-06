# Phase 1: Cook-Levin Theorem

## Statement

SAT is NP-complete. Membership in NP is immediate; NP-hardness follows from a polynomial-time many-one reduction from an arbitrary language L ∈ NP to SAT.

## Setup

Let L ⊆ Σ* be any language in NP. Then there exists a nondeterministic Turing machine M = (Q, Σ, Γ, δ, q₀, q_accept, q_reject) and a polynomial p such that:
- M decides L
- Every computation path of M on input of length n has length at most T := p(n)

Fix an arbitrary input x ∈ Σ* with |x| = n. Construct in polynomial time a CNF formula φ_x such that:

x ∈ L ⟺ φ_x is satisfiable.

## Computation Tableaux

Any computation of M on x of length ≤ T can be represented by a T × T tableau.

- Rows: successive configurations
- Columns: tape cells (at most T cells needed)
- Each cell holds a symbol from Γ' = Γ ∪ (Q × Γ)

A symbol (q, a) means "head is here, machine in state q, underlying tape symbol a."

## Propositional Variables

Introduce Boolean variable x_{i,j,σ} for every 0 ≤ i, j < T and every σ ∈ Γ'.

Meaning: "the symbol in row i, column j is σ."

Total variables: O(T² · |Γ'|) = O(p(n)²) — polynomial in n.

## Clauses of φ_x

### 1. Cell Uniqueness

For every cell (i,j) and distinct symbols σ ≠ τ:

(¬x_{i,j,σ} ∨ ¬x_{i,j,τ})

For every cell, the disjunction of all possible symbols:

⋁_{σ ∈ Γ'} x_{i,j,σ}

### 2. Initial Configuration

For each position j, force the unique correct symbol σ_j:

x_{0,j,σ_j}

### 3. Transition Consistency (Local Windows)

Enforce that every 2×3 window of the tableau is "legal."

Enumerate all legal 2×3 windows (finitely many, since Q and Γ are finite). For every position (i,j) with 0 ≤ i < T-1 and 0 ≤ j < T-2, and for every illegal window W, add a clause forbidding W.

Each clause is a disjunction of six negated literals. Total: O(T²) clauses.

### 4. Accepting State

⋁_{i,j} ⋁_{a ∈ Γ} x_{i,j,(q_accept,a)}

## Correctness

- If M has an accepting computation on x, the corresponding tableau yields a satisfying assignment.
- Conversely, any satisfying assignment defines a unique symbol per cell. Uniqueness + initial config clauses force row 0 to be the correct start config. Window clauses force every successive row to be a legal successor. Accepting-state clause forces the computation to accept.

## Complexity

φ_x can be written in time O(p(n)^c) for fixed constant c. Size of φ_x: O(p(n)^c). The map x ↦ φ_x is a polynomial-time many-one reduction.

## Remarks

- Same technique works for 3-SAT via standard CNF-to-3-CNF conversion
- Construction is completely effective once M and p are fixed
