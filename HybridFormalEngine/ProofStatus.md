# Proof Status Registry — HybridFormalEngine

Every proposition carries one status. Never upgrade unresolved merely because code compiles.
`NO SORRYS / NO ADMITS / NO PLACEHOLDERS` — every gap is an explicit `axiom` with status.

| # | File | Proposition | Kind | Status |
|---|------|-------------|------|--------|
| 1 | `01_AxiomaticFoundation.lean:14` | `FiniteSet` | DEFINITION | DEFINITION |
| 1 | `01_AxiomaticFoundation.lean:26` | `BVal` | DEFINITION | DEFINITION |
| 1 | `01_AxiomaticFoundation.lean:33` | `bNot/bAnd/bOr/bXor/bNand/bNor` | DEFINITION | DEFINITION |
| 1 | `01_AxiomaticFoundation.lean:42` | `Is3CNF` | DEFINITION | DEFINITION |
| 1 | `01_AxiomaticFoundation.lean:60` | `PolyBound / IsPolyTime` | DEFINITION | DEFINITION |
| 1 | `01_AxiomaticFoundation.lean:70` | `PrimeField` | DEFINITION | DEFINITION |
| 1 | `01_AxiomaticFoundation.lean:74` | `FieldOps` | AXIOM | **ASSUMED** |
| 1 | `01_AxiomaticFoundation.lean:86` | `Gate / Wire` | DEFINITION | DEFINITION |
| 2 | `02_ClassicalSAT.lean:14` | `evalLit/evalClause/evalCNF` | DEFINITION | DEFINITION |
| 2 | `02_ClassicalSAT.lean:21` | `SAT` | DEFINITION | DEFINITION |
| 2 | `02_ClassicalSAT.lean:25` | `bNot_involutive, bAnd_comm, bOr_comm` | THEOREM | **PROVED** |
| 2 | `02_ClassicalSAT.lean:29` | `threeSAT_subset_SAT` | THEOREM | **PROVED** |
| 2 | `02_ClassicalSAT.lean:34` | `ThreeSAT` | DEFINITION | DEFINITION |
| 3 | `03_CircuitSemantics.lean:13` | `Circuit C=(W,G,I,O)` | DEFINITION | DEFINITION |
| 3 | `03_CircuitSemantics.lean:23` | `evalGateKind / evalGate` | DEFINITION | DEFINITION |
| 3 | `03_CircuitSemantics.lean:36` | `evalCircuit` | AXIOM | **ASSUMED** (DAG topological order) |
| 3 | `03_CircuitSemantics.lean:40` | `cnf_to_circuit` | AXIOM | **CONJECTURE** |
| 3 | `03_CircuitSemantics.lean:43` | `sat_iff_circuit_exists` | AXIOM | **CONJECTURE** |
| 4 | `04_QuantumExtension.lean:16` | `Qubit, ket0/1, QState` | DEFINITION | DEFINITION |
| 4 | `04_QuantumExtension.lean:27` | `ComplexAxiom` | FOUNDATIONAL AXIOM | **FOUNDATIONAL AXIOM** (ℂ as Float) |
| 4 | `04_QuantumExtension.lean:38` | `tensorProduct` | AXIOM | **ASSUMED** |
| 4 | `04_QuantumExtension.lean:52` | `measure` | AXIOM | **ASSUMED** (probabilistic) |
| 4 | `04_QuantumExtension.lean:60` | `separation` | AXIOM | **ASSUMED** |
| 5 | `05_HybridCircuit.lean:11` | `HybridCircuit H=(C,Q,M,R)` | DEFINITION | DEFINITION |
| 5 | `05_HybridCircuit.lean:16` | `ClassicalPreprocess / MeasurementInterface` | AXIOM | **ASSUMED** |
| 5 | `05_HybridCircuit.lean:29` | `hybrid_is_probabilistic` | THEOREM | **DERIVED** |
| 6 | `06_HybridSAT.lean:10` | `SAT_exists / HybridSAT` | DEFINITION | DEFINITION |
| 6 | `06_HybridSAT.lean:19` | `verification_implies_existence` | THEOREM | **PROVED** |
| 6 | `06_HybridSAT.lean:23` | `search_not_imply_existence` | AXIOM | **CONJECTURE** |
| 6 | `06_HybridSAT.lean:26` | `quantum_speedup_claim` | DEFINITION | **UNRESOLVED** (False = no claim) |
| 7 | `07_VerificationPath.lean:10` | `Verify_SAT` | DEFINITION | DEFINITION |
| 7 | `07_VerificationPath.lean:15` | `verify_correct` | THEOREM | **PROVED** |
| 8 | `AdaSpark/sat_verifier.ads:28` | `Verify_SAT'Result = Eval_CNF` | CONTRACT | **DERIVED** (postcondition) |
| 8 | `AdaSpark/sat_verifier.adb:12` | `Eval_Clause` loop invariant | CONTRACT | **ASSUMED** (SPARK proof obligation) |
| 9 | `AdaSpark/circuit_evaluator.ads:14` | `Gate_Eval` | CONTRACT | **DERIVED** |
| 9 | `AdaSpark/circuit_evaluator.ads:27` | `Circuit_Eval` | CONTRACT | **ASSUMED** (DAG) |
|10 | `10_QuantumCircuitSpec.lean:13` | `U_Q, outputState` | DEFINITION | DEFINITION |
|10 | `10_QuantumCircuitSpec.lean:23` | `no_guarantee_without_proof` | AXIOM | **ASSUMED** |
|10 | `QASM/hybrid_grover.qasm:1` | `phase_oracle, diffuser` | CIRCUIT REP. | **DERIVED** (from GroverSearch.lean) |
|11 | `Stark/11_ZKTrace.lean:11` | `ExecutionTrace, ValidTrace` | DEFINITION | DEFINITION |
|11 | `Stark/11_ZKTrace.lean:24` | `zk_hiding` | AXIOM | **CONJECTURE** |
|12 | `Stark/12_Arithmetization.lean:14` | `AIR` | DEFINITION | DEFINITION |
|12 | `Stark/12_Arithmetization.lean:31` | `bool_to_field_correspondence` | AXIOM | **ASSUMED** |
|12 | `Stark/12_Arithmetization.lean:37` | `arithmetization_sound` | AXIOM | **CONJECTURE** |
|13 | `Stark/13_ZKStatement.lean:14` | `ZKStarkStatement` | DEFINITION | DEFINITION |
|13 | `Stark/13_ZKStatement.lean:27` | `stark_soundness` | AXIOM | **CONJECTURE** |
|14 | `Stark/14_QuantumStarkBoundary.lean:14` | `quantum_to_classical_simulation` | AXIOM | **ASSUMED** (simulation relation) |
|15 | `15_EndToEnd.lean:18` | `verified_iff_eval` | THEOREM | **PROVED** |
|15 | `15_EndToEnd.lean:23` | `chain_implication` | AXIOM | **ASSUMED** |
|18 | `18_UnifiedObject.lean:15` | `UnifiedObject H=(A,B,C,Q,T,F,Z,V)` | DEFINITION | DEFINITION |
|18 | `18_UnifiedObject.lean:26` | `central_invariant V(Z)=1 ⇒ ZKStarkStatement` | AXIOM | **ASSUMED** (needs stark_soundness) |
|18 | `18_UnifiedObject.lean:32` | `verified_iff_eval_unified` | THEOREM | **PROVED** |

**Global invariants:**
- `Verified(φ,a) ↔ Eval(φ,a)=1` — **PROVED** (`07_VerificationPath.lean:15`, preserved in `18_UnifiedObject.lean:32`)
- `V(Z)=1 ⇒ Z proves computation relation` — **ASSUMED** (requires `stark_soundness`)
- `P vs NP` — **UNRESOLVED** (no axiom assumes equality/inequality; `SharedFoundation/PinNP.lean:pVsNP_status=.unresolved`)
- `Quantum advantage` — **UNRESOLVED** (no claim without complexity proof)
- `ZK privacy` — **CONJECTURE** (no claim without hiding argument)
- `STARK soundness` — **CONJECTURE** (needs FRI/field assumptions)

EVERY formal gap is labeled above. No `sorry`, no `admit`, no silent assumption.
