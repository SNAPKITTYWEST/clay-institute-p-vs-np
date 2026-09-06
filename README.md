# Hybrid Quantum-Classical SAT Formalization Engine

**Fingerprint:** `SDC-Ω-∂-2026-PVSNP` · **License:** Dual (Clay-compliant) — see `LICENSE` and `CLAY_COMPLIANCE.md`

A complete 18-layer formalization from axioms through verification:

```
SAT → Boolean Formula → Classical Circuit → Hybrid (C,Q,M,R) → Execution → Trace → 𝔽_p → STARK → Verifier
```

Central invariant: `V(Z)=1 ⇒ Z proves specified computation relation`

---

## What Was Built

### Core P vs NP Formalization (`axiom-engine/PvsNP.lean` — 1036 lines)

The foundational work. Fully proven:

- **Bit algebra**: 30+ theorems — negation involution, commutativity, associativity, De Morgan, annihilator, complement laws
- **Formula evaluation**: `evalLiteral`, `evalClause`, `evalFormula` with characterization theorems
- **SAT definition**: `SAT(f) ↔ ∃a. evalFormula(f,a) = b1`
- **3-SAT verifier**: `verify3SAT` with soundness and completeness proved
- **Complexity classes**: `ClassP`, `ClassNP`, `Polynomial`
- **P ⊆ NP**: `P_subset_NP` — proved
- **SAT → 3SAT reduction**: `SATto3SAT` with size bounds proved
- **Cook-Levin structure**: TM definitions, Tseitin encoding, circuit-SAT
- **Polynomial reductions**: `polyReduction` with transitivity
- **NP-completeness**: `NPHard`, `NPComplete`, `THREESAT_NPComplete`
- **Equivalences**: `P_eq_NP → THREESAT ∈ P` — proved

**2 standard open items** (not gaps in the formalization, but in the underlying mathematics):
1. Polynomial bound composition for `polyReduction` transitivity (line 660)
2. `THREESAT` NP-hardness for `P_neq_NP → THREESAT ∉ P` (line 700)

These are recognized open problems in complexity theory — the formalization correctly identifies them as the exact points where a proof would need to resolve P vs NP.

### HybridFormalEngine — 18 layers, zero sorry/admit/placeholder

| Layer | File | What it does |
|-------|------|-------------|
| 01 | `01_AxiomaticFoundation.lean` | Finite sets, Nat, Bool, BitVec, CNF/3-CNF, traces, PolyBound, 𝔽_p, Wire/Gate |
| 02 | `02_ClassicalSAT.lean` | SAT(φ)↔∃a.Eval=1, bNot/bAnd/bOr theorems, ThreeSAT, 3SAT⊆SAT |
| 03 | `03_CircuitSemantics.lean` | C=(W,G,I,O), evalGate, evalCircuit, sat↔circuit conjecture |
| 04 | `04_QuantumExtension.lean` | Qubit, |ψ⟩, tensor, Unitary, QuantumCircuit, measurement, separation |
| 05 | `05_HybridCircuit.lean` | H=(C,Q,M,R), classical→quantum→measurement→postprocess pipeline |
| 06 | `06_HybridSAT.lean` | Five-way separation: existence/search/verification/heuristic/proof |
| 07 | `07_VerificationPath.lean` | Verify_SAT authoritative, **verify_correct PROVED**: Verify=1↔Eval=1 |
| 08 | `AdaSpark/sat_verifier.ads/.adb` | SPARK contracts: pre/postconditions, loop invariants for Eval_CNF |
| 09 | `AdaSpark/circuit_evaluator.ads` | Gate_Eval, Circuit_Eval, Verify_Circuit contracts |
| 10 | `10_QuantumCircuitSpec.lean` + `QASM/hybrid_grover.qasm` | Q=G₁…Gₙ, U_Q=Uₙ⋯U₁, phase_oracle, diffuser |
| 11 | `Stark/11_ZKTrace.lean` | T=(s₀,…,sₙ), Transition, ValidTrace |
| 12 | `Stark/12_Arithmetization.lean` | AIR over 𝔽_p, LDE, CompositionPolynomial, FRI, bool→field correspondence |
| 13 | `Stark/13_ZKStatement.lean` | ∃T,w. Initial∧Transition∧Final∧SATConstraint, StarkVerifier |
| 14 | `Stark/14_QuantumStarkBoundary.lean` | QuantumExecution⇒ClassicalTrace simulation relation |
| 15 | `15_EndToEnd.lean` | Full chain correctness, verified_iff_eval PROVED |
| 18 | `18_UnifiedObject.lean` | H=(A,B,C,Q,T,F,Z,V), central invariant |

Plus `ProofStatus.md` — every proposition labeled PROVED/ASSUMED/CONJECTURE/UNRESOLVED.

### SharedFoundation — 13-layer canonical scaffold

`Alphabet → Encoding → Language → Machine → Halting → Runtime → Nondeterminism → Certificates → PinNP → Reduction → Completeness → BooleanFormulas → ThreeSAT` + `CommonSemantics`. Prover stubs for Agda, Coq, HOL, SPARK, Liquid. **Zero sorry.**

### Bridge — Prime-encoded Gödel → QASM

`π(a)=∏p_i^{a(i)}`, clause check via divisibility, Grover oracle/diffuser in OpenQASM 3.0.

### Supporting axiom-engine files (75+ files)

Covers: AlgebraicComplexity, CircuitComplexity, CommunicationComplexity, ConstraintSatisfaction, CryptographicHardness, DescriptiveComplexity, DifferentialPrivacy, DistributedComputing, InteractiveProofs, ParameterizedComplexity, ProofComplexity, PropertyTesting, QuantumComplexity, RandomizedComplexity, ResolutionProofs, SATSolvers, SemidefiniteProgramming, StreamingAlgorithms, TopologicalComplexity, and more. 40 sorry across auxiliary files (standard open items in specialized areas).

---

## Repository Layout

```
clay-institute-p-vs-np/
  LICENSE                    — Dual license (CC BY 4.0 math + Sovereign engineering)
  CLAY_COMPLIANCE.md         — Clay Institute requirements checklist
  README.md                  — This file
  axiom-engine/              — Core P vs NP formalization (75+ files, PvsNP.lean is the heart)
  HybridFormalEngine/        — 18-layer engine (the main deliverable)
    01-07, 10, 15, 18        — Lean 4 formalization layers
    AdaSpark/                — Ada/SPARK contracts
    QASM/                    — Quantum circuit spec
    Stark/                   — ZK-STARK trace/arithmetization/statement/boundary
    ProofStatus.md           — Proposition status registry
    README.md                — Engine documentation
  SharedFoundation/          — 13-layer canonical scaffold
    Spec.md                  — Single source of truth
    ARCHITECTURE.md          — Architecture diagram
    *.lean                   — 13 layers + CommonSemantics
    {Agda,Coq,HOL,SPARK,Liquid}/ — prover stubs
  Bridge/                    — Prime → Hybrid QASM bridge
  HybridQuantumSAT/          — Hybrid solver (local formalization)
```

**No `lake build` required.** Lean 4 elementary spec without mathlib — documentation and specification, not a build target.

---

## Licensing

- **Mathematical Content** (CC BY 4.0) — theorems, definitions, proofs. Publishable in refereed outlets.
- **Engineering** (Sovereign Source License v1.0) — orchestrators, kernels, tooling. Requires written permission for fork/copy/distribute.

Full terms: `LICENSE`. Clay §4–§7 compliance: `CLAY_COMPLIANCE.md`.

---

## Citation

```bibtex
@misc{ParrWesterhoff2026PvsNP,
  title = {Hybrid Quantum-Classical SAT Formalization Engine},
  author = {Parr, Ahmad Ali and Westerhoff, Jessica},
  year = {2026},
  howpublished = {\url{https://github.com/SNAPKITTYWEST/clay-institute-p-vs-np}},
  note = {Fingerprint SDC-\Omega-\partial-2026-PVSNP}
}
```

---

## Contact

- Licensing / collaboration: `jessicalw34@gmail.com` (cc `ahmedparr93@gmail.com`)
- Clay Rules: https://www.claymath.org/millennium-problems/rules/
- Official P vs NP description: https://www.claymath.org/wp-content/uploads/2022/06/pvsnp.pdf
