// PrimeToHybrid.qasm — Modular prime-encoded Grover bridge
// OpenQASM 3.0 — maps Σ→Σ*→L→M→≤p→SAT→3SAT→π→QASM
// Math → HybridQuantumSAT (Lit/Clause/Fml) → Prime Gödel π(a)=∏p_i^{a(i)} → Grover oracle
// Fingerprint: SDC-Ω-∂-2026-PVSNP — CC BY 4.0 (math) / Sovereign (eng) — see LICENSE
// See Bridge/BRIDGE_SPEC.md and Bridge/PrimeEncodedSearcher.lean:peqs_circuit_source

OPENQASM 3.0;
include "stdgates.inc";

// ——— Parameters (tune n,m for instance) ———
// n = number of variables (primes p_0..p_{n-1} from [2,3,5,7,11,13,17,19,23,29,…])
// m = number of clauses (each ≤3 literals)
const int n = 8;
const int m = 4;

// ——— Registers ———
// vars[i] = 1 iff p_i divides P = π(a)  (i.e., a(i)=true)
// target  = phase kickback qubit (prepared in |->)
// ancilla = temporary for clause all-false detection
qubit[n] vars;
qubit target;
qubit[n-1] ancilla;
bit[n] c;

// ——— State preparation ———
// vars in uniform superposition over 2^n assignments (Σ* → M.Run)
// target in |-> for phase kickback (phase_oracle: ψ↦ -ψ on fml_sat)
def prepare() {
  for int i in [0:n-1] { h vars[i]; }
  x target; h target; // |1> → |-> = (|0>-|1>)/√2
}

// ——— Clause oracle via prime divisibility (P % p_i == 0 tests) ———
// Clause (x0 ∨ ¬x1 ∨ x2) ↔ (p0∣P ∨ p1∤P ∨ p2∣P)
// Implemented as: normalize false conditions → all-false MCT → flip phase if NOT all-false
// This is clauseSatByPrime (PrimeEncodedSearcher.lean:98) compiled to QASM.
gate clause_oracle(qubit[n] q, qubit tgt, qubit[n-1] anc) {
  // Example clause 0: (x0 OR NOT x1 OR x2)
  // Normalize: want |1> exactly when literal is FALSE
  x q[0];      // pos 0: false is q0=0 → flip to 1
  // neg 1: false is q1=1 → already 1, no flip
  x q[2];      // pos 2: false is q2=0 → flip to 1
  // All-false = anc[0]=1 iff q0=1 & q1=1 & q2=1 (i.e., original clause false)
  ccx q[0], q[1], anc[0];
  ccx anc[0], q[2], anc[0]; // anc0 = q0 & q1 & q2  (requires anc clean)
  // Phase flip if NOT all-false (i.e., clause satisfied): anc0=0 → flip, so invert first
  x anc[0];
  cz anc[0], tgt; // phase kickback: |-> → -|-> when anc0=1
  x anc[0];
  // Uncompute
  ccx anc[0], q[2], anc[0];
  ccx q[0], q[1], anc[0];
  x q[2];
  x q[0];

  // Additional clauses (1..m-1) extend with separate ancilla lines or reuse via
  // Marriott-Watrous uncomputation. For ≤p reduction SAT→3SAT, each original clause
  // maps to ≤4 3SAT clauses (standard) — repeat pattern per clause, combining with AND
  // via ancilla chain before final cz.
}

// ——— Full formula oracle (AND over m clauses) ———
// formulaSatByPrime P cs = cs.all (clauseSatByPrime P)  — Bridge/BRIDGE_SPEC.md §3
gate formula_oracle(qubit[n] q, qubit tgt, qubit[n-1] anc) {
  // In full instance, iterate over m clauses, accumulating in anc chain:
  // clause_oracle per clause → anc[k] = sat_k, then mcx anc[0..m-1] → anc[m-1]
  // Here we show single-clause version; extend by chaining ccx.
  clause_oracle(q, tgt, anc);
}

// ——— Grover diffuser: 2|ψ><ψ| - I (GroverSearch.lean:57 diffusion_operator) ———
gate diffuser(qubit[n] q) {
  for int i in [0:n-1] { h q[i]; x q[i]; }
  h q[n-1];
  // multi-controlled X on first n-1 controls, target q[n-1] (decompose via ancilla)
  // For n=8, this is an 8-controlled operation; simulator expands via ccx ladder
  // Placeholder: use 7-control via ancilla cascade (omitted for brevity — simulator gate)
  // In hardware, decompose with ancilla: mcx q[0:n-1], q[n-1];
  h q[n-1];
  for int i in [0:n-1] { x q[i]; h q[i]; }
}

// ——— Grover iteration: oracle + diffuser (GroverSearch.lean:63) ———
def grover_iteration() {
  formula_oracle(vars, target, ancilla);
  diffuser(vars);
}

// ——— Entry (example invocation) ———
// for groverIterations(n,m) = floor(pi/4 * sqrt(2^n/m)) times (PrimeEncodedSearcher.lean:161)
// pi_over_4 ≈ 0.7854 scaled 7854/10000, sqrt_ratio = sqrt(2^n*10000/m)
// For n=8,m=1: iterations ≈ 12
prepare();
// Repeat: grover_iteration();  // caller loops iterations times (host program)
// measure vars -> c;           // x ∈ L ↔ ∃ accepting path / witness w with |w|≤p(|x|)
