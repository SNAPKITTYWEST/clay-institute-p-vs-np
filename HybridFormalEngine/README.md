# Hybrid Quantum-Classical SAT Formalization Engine

**Fingerprint:** `SDC-Ω-∂-2026-PVSNP` · **License:** CC BY 4.0 (math) / Sovereign (eng) · **Status:** P vs NP **UNRESOLVED**

One consistent spec from axioms to verifier:

```
SAT ↓ Boolean Formula ↓ Classical Circuit ↓ Hybrid (C,Q,M,R) ↓ Execution ↓ Trace ↓ 𝔽_p ↓ STARK ↓ Verifier
STARK Verified ⇒ Trace Valid ⇒ Execution Valid ⇒ Circuit Valid ⇒ SAT Verification Valid
```

## Layout (no `lake build` — elementary, IDE-safe)

```
HybridFormalEngine/
  01_AxiomaticFoundation.lean  — finite sets, Nat, Bool, BitVec, CNF/3-CNF, traces, PolyBound, 𝔽_p, W/G
  02_ClassicalSAT.lean         — SAT(φ)↔∃a.Eval=1, bNot/bAnd/…, ThreeSAT, 3SAT⊆SAT (PROVED)
  03_CircuitSemantics.lean     — C=(W,G,I,O), Eval_G, Eval_C (axiomatized), sat_iff_circuit_exists (CONJECTURE)
  04_QuantumExtension.lean     — qubit, |ψ>, tensor, Unitary, QuantumCircuit, measure (probabilistic)
  05_HybridCircuit.lean        — H=(C,Q,M,R), Classical→Quantum→Measurement→Postprocess
  06_HybridSAT.lean            — HybridSAT, separation existence/search/verification/heuristic/proof
  07_VerificationPath.lean     — Verify_SAT, verify_correct (PROVED): Verify=1 ↔ Eval=1
  AdaSpark/sat_verifier.ads/.adb     — SPARK pre/post, loop invariants for Eval_CNF
  AdaSpark/circuit_evaluator.ads     — Gate_Eval, Circuit_Eval, Verify_Circuit contracts
  QASM/hybrid_grover.qasm      — Q= G1..Gn, U_Q=Un⋯U1, |ψ_out>=U_Q|ψ_in>, diffuser
  10_QuantumCircuitSpec.lean   — U_Q definition, no_guarantee_without_proof (ASSUMED)
  Stark/11_ZKTrace.lean        — T=(s0..sn), Transition, zk_hiding (CONJECTURE)
  Stark/12_Arithmetization.lean— AIR over 𝔽_p, LDE, composition polynomial, FRI, bool→field (ASSUMED)
  Stark/13_ZKStatement.lean    — ∃T,w. Initial∧Transition∧Final∧SATConstraint, stark_soundness (CONJECTURE)
  Stark/14_QuantumStarkBoundary.lean — QuantumExecution⇒ClassicalTrace simulation relation (ASSUMED)
  15_EndToEnd.lean             — chain, verified_iff_eval (PROVED)
  18_UnifiedObject.lean        — H=(A,B,C,Q,T,F,Z,V), central invariant V(Z)=1⇒statement (ASSUMED)
  ProofStatus.md               — every proposition labeled PROVED/ASSUMED/CONJECTURE/UNRESOLVED
```

## Central Invariants (boxed)

```
V(Z)=1 ⇒ Z proves specified computation relation          (ASSUMED via stark_soundness)
Verified(φ,a) ↔ Eval(φ,a)=1                               (PROVED, 07+18)
```

Preserved through: math spec → circuit (Ada/SPARK) → hybrid execution → arithmetic trace → STARK → verifier.

## No Unsound Shortcuts

`NO SORRYS / NO ADMITS / NO PLACEHOLDERS / NO UNSTATED AXIOMS` — every gap is an explicit `axiom` with status in `ProofStatus.md`. No claim of quantum advantage without complexity proof, no ZK without hiding argument, no STARK soundness without FRI/field assumptions, no P vs NP consequence.

## Bridge to Existing Tracks

- Mathematical: `formal-conjectures/FormalConjectures/Millenium/PvsNP.lean` (List Bool→Bool)
- Hybrid: `HybridQuantumSAT/` (Lit/Clause/Fml, GroverSearch)
- Prime→QASM bridge: `Bridge/` (π(a)=∏p_i^{a(i)}, `Bridge/PrimeToHybrid.qasm`)

See `SharedFoundation/` (13-layer Σ→…→3SAT, CommonSemantics) and `Bridge/BRIDGE_SPEC.md`.

## Licensing & Clay

Math content CC BY 4.0 for refereed publication (Qualifying Outlet, ≥2 years, general acceptance); engineering Sovereign Source License v1.0. See `LICENSE` and `CLAY_COMPLIANCE.md`. This repo is NOT a Qualifying Outlet and NOT a submission to CMI.

## Verification

Inspect `ProofStatus.md` for the authoritative status of every proposition. Do not upgrade UNRESOLVED because code compiles.
