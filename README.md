# CLAY INSTITUTE P vs NP — Shared Foundation + Hybrid Quantum Bridge

**Fingerprint:** `SDC-Ω-∂-2026-PVSNP` · **Status:** P vs NP **UNRESOLVED** · **License:** Dual (Clay-compliant) — see `LICENSE` and `CLAY_COMPLIANCE.md`

> If it is easy to check that a solution to a problem is correct, is it also
> easy to solve the problem? — Clay Mathematics Institute, P vs NP description
> (Cook 2000, https://www.claymath.org/wp-content/uploads/2022/06/pvsnp.pdf)

---

## 1. What This Repository Is

A **Clay-compliant formalization scaffold** for the P vs NP problem that:

- Implements the canonical boxed chain as a single source of truth:

  ```
  Σ → Σ* → L → M → Run → T → P/NP → ≤p → SAT → 3SAT
  ```

- Bridges two local formalizations:
  - **Mathematical track** — `formal-conjectures/FormalConjectures/Millenium/PvsNP.lean`
    (`ComplexityTheory` namespace: `DecisionProblem := List Bool → Bool`,
    `P`/`NP` via `TM2ComputableInPolyTime` / verifier `∃ p R`,
    theorems `P_ne_NP`, `P_subset_NP`, `coP_eq_P`)
  - **Hybrid quantum track** — `HybridQuantumSAT/` (Lit/Clause/Fml/Asgn,
    `reduce`, `quantum_search`, Grover `phase_oracle`/`diffusion_operator`,
    `HybridQuantumSAT.Proofs.Main.hybrid_correct`)

- Provides a **prime-number → hybrid bridge in OpenQASM 3.0** (prime-encoded
  Gödel numbering `π(a)=∏ p_i^{a(i)}`, clause check via `P % p_i == 0`,
  Grover oracle/diffuser circuits) under `Bridge/`.

Proof assistants are **implementations**, not definitions. See
`SharedFoundation/Spec.md` and `SharedFoundation/ARCHITECTURE.md`:

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

---

## 2. Licensing — Clay Compliant Dual License

**Summary:** Mathematical content is publishable; engineering remains sovereign.

- **Mathematical Content (CC BY 4.0 + Apache 2.0)** — `SharedFoundation/*`,
  `HybridQuantumSAT/Basic/*`, `Bridge/*` spec, theorem statements/definitions.
  Granted for: reproducing, sharing, adapting, publishing in a **refereed
  mathematics publication of worldwide repute** (Qualifying Outlet), arXiv
  deposit, MathSciNet indexing, citation, verification. Requires attribution:

  > © 2026 Ahmad Ali Parr + Jessica Westerhoff, Bel Esprit d'Accord Trust  
  > https://github.com/SNAPKITTYWEST/CLAY-INSTITUTE-P-VS-NP — SDC-Ω-∂-2026-PVSNP

- **Engineering Implementation (Sovereign Source License v1.0)** — orchestrators,
  proprietary kernels, non-mathematical tooling. Viewing and citing theorem
  names permitted; forking/copying/distribution/commercial use requires
  written permission (`jessicalw34@gmail.com`).

Full terms: `LICENSE` §3–§5. No file may be taken as granting more than its
header states. Fingerprint `F(53)%107=8, π(108)=72, 64=55+8+1` establishes
provenance (`SovereignFingerprint.lean`).

---

## 3. Clay Institute Requirements

This repository **is not a submission** to CMI and **is not a Qualifying
Outlet** (Rules §6.b). A Clay-eligible Proposed Solution must (Rules §4,
§6–§7, https://www.claymath.org/millennium-problems/rules/):

1. **Be published** in a Qualifying Outlet: named editorial board, qualified
   editors, published refereeing process, MathSciNet-indexed (§6.e). CMI
   will not recommend outlets or certify them (§6.b–c).

2. **Wait ≥2 years** post-publication.

3. **Achieve general acceptance** in the global mathematics community
   (independent citations, international conferences, awards, detailed
   scrutiny — in CMI's sole discretion, §7.a.i).

4. **Pass CMI examination**: SAB, if it finds general acceptance + ≥2 years,
   may constitute a Special Advisory Committee (≥1 SAB + ≥2 non-SAB experts)
   verifying each component (§7.a.ii). For P vs NP, resolution in **either
   direction** qualifies (§4.b).

5. **Address Cook's official description** specifically (§4.d); supplementary
   material sent to CMI will not be considered (§6.d, §7).

Authors in this repository are granted an irrevocable right to submit the
Mathematical Content to any Qualifying Outlet and transfer customary
publication rights (`LICENSE` §5). Details: `CLAY_COMPLIANCE.md`.

---

## 4. Repository Layout

```
clay-institute-p-vs-np/
  LICENSE                 — Dual license, Clay §4–§7 summary
  CLAY_COMPLIANCE.md      — Full Clay checklist
  README.md               — This file
  SharedFoundation/       — Canonical 13-layer scaffold (elementary, no Lake build)
    Spec.md               — Single source of truth, boxed chain
    ARCHITECTURE.md       — Computation / Complexity / Logic → 5 provers
    Alphabet.lean … ThreeSAT.lean (13 layers) + CommonSemantics.lean
    Agda/ Coq/ HOL/ SPARK/ Liquid/ — prover stubs targeting same semantics
  HybridQuantumSAT/       — Hybrid solver (local formalization)
    Basic/Definitions.lean — Lit, Clause, Fml, Asgn, lit_val, clause_sat, fml_sat
    Basic/Axioms.lean      — reduce_sound, quantum_correct
    Proofs/Main.lean       — hybrid, hybrid_correct
    Quantum/GroverSearch.lean — phase_oracle, diffusion_operator, grover_search
  Bridge/                 — Prime-number ↔ hybrid bridge (NEW)
    PvsNP_Hybrid_Bridge.lean — maps ComplexityTheory P/NP ↔ Hybrid Fml + primes
    PrimeEncodedSearcher.lean — Gödel π(a)=∏p_i^{a(i)}, clauseSatByPrime (from axiom-engine)
    PrimeToHybrid.qasm     — OpenQASM 3.0 prime-encoded Grover oracle + diffuser
    PrimeToHybrid_Full.qasm— Full n=8 example with measurement
    BRIDGE_SPEC.md         — Mathematical justification
  formal-conjectures/FormalConjectures/Millenium/PvsNP.lean — Upstream mathematical track (Apache 2.0, List Bool → Bool)
```

**No `lake build` is required.** `SharedFoundation/` is elementary Lean 4
without `mathlib`; it is documentation/spec, not a build target — per
directive to avoid IDE crashes.

---

## 5. Bridge — Mathematical Prime Number → Hybrid (OpenQASM)

The bridge formalizes the equivalence between the verifier formulation of NP
(ComplexityTheory: `L x ↔ ∃ w, |w|≤p(|x|) ∧ R(x,w)`) and the hybrid quantum
SAT evaluation (`fml_sat`), via prime-encoded Gödel numbering:

- **Encoding**: `assignmentToPrimeProduct : (Fin n → Bool) → Nat`
  `π(a) = ∏ p_i^{a(i)}` square-free (primes `2,3,5,7,11,…`). Injective by FTA.
  Inverse: `primeProductToAssignment n P i := P % p_i ≠ 0`.

- **Clause check via divisibility**:
  `Literal.pos i` satisfied iff `P % p_i == 0`; `Literal.neg i` iff `P % p_i != 0`
  (`Bridge/PrimeToHybrid.qasm:clause_sat` uses ancilla + MCT to detect all-false).

- **Formula**: `formulaSatByPrime P clauses := clauses.all (clauseSatByPrime P)`
  preserves `SAT(φ) ↔ ∃ a eval(φ,a)=1` (12_BooleanFormulas.lean) and maps to
  `ThreeSATLanguage` (13_ThreeSAT.lean).

- **Quantum resources**: `P ≤ (p_{n-1})^n`, qubit count `n + log₂(P) + 1 = O(n log n)`,
  Grover iterations `⌊π/4·√(2^n/m)⌋` (`groverIterations` in PrimeEncodedSearcher.lean:161).

- **OpenQASM 3.0**: `Bridge/PrimeToHybrid.qasm` implements `clause_oracle` (phase
  flip on `ancilla` via `cz`) and `diffuser` (`2|ψ⟩⟨ψ|-I`), instantiated for
  `n=8` in `PrimeToHybrid_Full.qasm` with `qreg q[8]`, `h` superposition,
  and `measure`. See `Bridge/BRIDGE_SPEC.md` for the `Σ → Σ* → L` → QASM
  compilation via `enc` (Encoding.lean).

Run with any OpenQASM 3.0 simulator (e.g., Qiskit `qasm3.load`, `qasm_simulator`):
`qasm3.load("Bridge/PrimeToHybrid.qasm")`.

---

## 6. How to Cite / Verify

Mathematical content may be cited, refereed, and deposited per `LICENSE` §4–§5.
Verification should target the boxed chain and bridge invariants; P vs NP
remains **unresolved** (`PinNP.lean:pVsNP_status = .unresolved`, no axiom
assumes equality/inequality).

```
@misc{ParrWesterhoff2026PvsNP,
  title = {Shared Foundation for P vs NP: \Sigma\to\Sigma^*\to L\to M\to Run\to T\to P/NP\to\le_p\to SAT\to3SAT},
  author = {Parr, Ahmad Ali and Westerhoff, Jessica},
  year = {2026},
  howpublished = {\url{https://github.com/SNAPKITTYWEST/CLAY-INSTITUTE-P-VS-NP}},
  note = {Fingerprint SDC-\Omega-\partial-2026-PVSNP; CC BY 4.0 for mathematical content}
}
```

---

## 7. Contact

- Licensing / collaboration: `jessicalw34@gmail.com` (cc `ahmedparr93@gmail.com`)
- Clay Rules: https://www.claymath.org/millennium-problems/rules/
- Official P vs NP description: https://www.claymath.org/wp-content/uploads/2022/06/pvsnp.pdf

*The sovereign calculus is not free to take. The mathematics is free to verify.*
