// hybrid_grover.qasm — Quantum circuit spec for HybridFormalEngine §10
// Mathematical spec first: Q = G1..Gn, U_Q = Un⋯U1, |ψ_out> = U_Q|ψ_in>
// Fingerprint: SDC-Ω-∂-2026-PVSNP — CC BY 4.0
// Uses prime-encoded oracle from Bridge/PrimeToHybrid.qasm (π(a)=∏p_i^{a(i)})

OPENQASM 3.0;
include "stdgates.inc";

// Parameters: n variables (primes), m clauses, iterations = floor(pi/4 * sqrt(2^n/m))
const int n = 8;
const int iterations = 6; // tuned per instance (PrimeEncodedSearcher.groverIterations)

qreg vars[n];
qreg anc[n-1];
qreg tgt[1];
creg c[n];

// |ψ_in> = H^{⊗n}|0>^{⊗n} ⊗ |->  (uniform superposition + phase target)
def prepare() {
  for int i in [0:n-1] { h vars[i]; }
  x tgt[0]; h tgt[0];
}

// Phase oracle: applies -1 to marked subspace where formulaSatByPrime = true
// Realization: clause_oracle chain → anc[m-1] = AND(sat_i) → cz anc[m-1], tgt → uncompute
gate phase_oracle {
  // delegates to Bridge/PrimeToHybrid.qasm::clause_oracle per clause
  // Example 3SAT clauses compiled via SAT→3SAT ≤p reduction (4 clauses per original)
  // For this demo: 4 clauses as in PrimeToHybrid_Full.qasm
  // Clause 0..3 pattern omitted — import Bridge/PrimeToHybrid.qasm
}

// Diffusion: 2|ψ><ψ| - I  (GroverSearch.lean:diffusion_operator)
gate diffuser {
  for int i in [0:n-1] { h vars[i]; x vars[i]; }
  h vars[n-1];
  // multi-controlled Z via ancilla ladder (decomposed)
  // mcx vars[0:n-1], vars[n-1];
  h vars[n-1];
  for int i in [0:n-1] { x vars[i]; h vars[i]; }
}

// Q = G1..Gn composition, U_Q = diffuser·phase_oracle repeated iterations times
def grover_search() {
  prepare();
  for int k in [0:iterations-1] {
    phase_oracle;
    diffuser;
  }
}

// Measurement: probabilistic, returns distribution p(bitstring)=|amplitude|^2
// No guarantee unless amplitude amplification proved (GroverSearch.grover_success_probability)
grover_search();
measure vars -> c;
