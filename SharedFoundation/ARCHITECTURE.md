# Architecture — Common Semantic Layer

```
                 SHARED FOUNDATION  (Spec.md, 13 layers)
                        │
        ┌───────────────┼───────────────┐
        │               │               │
   Computation       Complexity       Logic
    (M, Run, T)      (P, NP, ≤p)   (SAT, 3SAT)
        │               │               │
        └───────────────┼───────────────┘
                        │
                 Common Semantics  (CommonSemantics.lean)
                        │  boxed chain Σ → Σ* → L → M → Run → T → P/NP → ≤p → SAT → 3SAT
       ┌────────┬───────┼───────┬──────────┐
       │        │       │       │          │
     Agda     Coq     HOL    SPARK    Liquid
     .agda    .v      .thy    .ads      .hs
```

## Rule
Proof assistants are **implementations**, not definitions. Divergence = bug.

## Conformance
Each prover directory under `SharedFoundation/{Agda,Coq,HOL,SPARK,Liquid}/`
implements the same `CommonSemantics Bin` record. Hash of Spec.md is the gate.

## Layers → Files

| Layer | Concept | Lean file |
|-------|---------|-----------|
| 1 | Σ, Σ*, {0,1} | `01_Alphabet.lean` |
| 2 | enc/dec | `02_Encoding.lean` |
| 3 | L⊆Σ*, x∈L | `03_Language.lean` |
| 4 | M, C, δ | `04_Machine.lean` |
| 5 | C_accept/reject, decides | `05_Halting.lean` |
| 6 | T_M, n=\|x\|, P | `06_Runtime.lean` |
| 7 | δ(C)⊆C, tree | `07_Nondeterminism.lean` |
| 8 | w, V, NP | `08_Certificates.lean` |
| 9 | P⊆NP, P=?NP | `09_PinNP.lean` |
|10 | A≤p B | `10_Reduction.lean` |
|11 | NP-hard/complete | `11_Completeness.lean` |
|12 | B, eval, SAT | `12_BooleanFormulas.lean` |
|13 | 3CNF, 3SAT∈NP | `13_ThreeSAT.lean` |

HybridQuantumSAT (`HybridQuantumSAT/`) is an **orthogonal** hybrid solver example;
it imports but does not redefine the shared chain.
