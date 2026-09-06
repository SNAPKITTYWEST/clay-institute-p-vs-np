# Phase 2: APL Problem Generator

## hard_sat.apl

```apl
⍝ APL 3-SAT Hard Instance Generator (Phase Transition Ratio c/v ≈ 4.26)
generate_hard_sat ← {
    v ← ⌷⍴,α ⍝ number of variables
    c ← ⌈ 4.26 × v ⍝ number of clauses
    vars ← ⍳v
    clause_matrix ← 3 (⍴,c) ⍴ ? c × 3 ⍴ v
    signs ← 1 - 2 × ? c × 3 ⍴ 2
    instance ← clause_matrix × signs
    instance
}
```

## Description

Generates 3-SAT instances at the critical clause-to-variable ratio c/v ≈ 4.26, where the phase transition between satisfiable and unsatisfiable instances occurs.
