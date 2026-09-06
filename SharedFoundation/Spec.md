# Shared Foundation — Canonical Spec
# Σ → Σ* → L → M → Run → T → P/NP → ≤p → SAT → 3SAT

This file is the **single source of truth**. All five prover implementations
(Agda, Coq, HOL, SPARK, Liquid Haskell) target this structure, not independent definitions.

```
                 SHARED FOUNDATION
                        │
        ┌───────────────┼───────────────┐
        │               │               │
   Computation       Complexity       Logic
        │               │               │
        └───────────────┼───────────────┘
                        │
                 Common Semantics
                        │
       ┌────────┬───────┼───────┬──────────┐
       │        │       │       │          │
     Agda     Coq     HOL    SPARK    Liquid
```

## Boxed Chain

```
Σ → Σ* → L → M → Run → T → P/NP → ≤p → SAT → 3SAT
```

Proof assistants are **implementations** of the formalization, not different definitions.

## 13 Layers

1. Alphabet: finite nonempty Σ, Σ*, binary Σ={0,1}
2. Encoding: enc: X→Σ*, dec: Σ*⇀X, dec(enc(x))=x
3. Decision Language: L⊆Σ*, x∈L, L(x):Bool/Prop, question Does x∈L?
4. Deterministic Machine: M, C, δ:C→C, C0→…→Ct with encoded input
5. Halting: C_accept, C_reject, M(x)=1 iff x∈L with termination
6. Runtime: T_M(x), n=|x|, ∃c,k T_M(x)≤c|x|^k ⇒ P
7. Nondeterminism: δ(C)⊆C, computation tree, x∈L iff ∃ accepting path
8. Certificates: w, V(x,w), |w|≤p(|x|), T_V≤q(|x|) ⇒ NP
9. P Inclusion: deterministic ⇒ single-branch nondet ⇒ P⊆NP, P=NP vs P≠NP unresolved
10. Reduction: A≤p B via poly-time f, x∈A ↔ f(x)∈B
11. NP-Completeness: NP-hard (∀A∈NP A≤p L), NP-complete (∈NP + hard)
12. Boolean Formulas: B={0,1}, vars, a:{0…n-1}→B, eval, SAT(φ) iff ∃a eval=1
13. 3-SAT: 3-CNF C1∧…∧Cm ≤3 literals, 3SAT∈NP, then reduction machinery

## Design Principles

- Provers share semantics; any divergence is a bug, not a feature.
- P vs NP remains UNRESOLVED at foundation layer — no axiom assumes equality or inequality.
- Lean/Agda/Coq/HOL/SPARK/Liquid each provide a total embedding of the same Σ-chain.
- Every finite object (formula, circuit, TM, certificate, reduction) enters via enc/dec.
