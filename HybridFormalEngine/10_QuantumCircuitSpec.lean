/-
Copyright 2026 — CC BY 4.0
HybridFormalEngine — 10 Quantum Circuit Specification
Q = G1..Gn, U_Q = Un⋯U1, |ψ_out> = U_Q|ψ_in>, measurement probabilities
-/
import HybridFormalEngine.«04_QuantumExtension»

namespace HybridFormalEngine.QuantumCircuitSpec

open QuantumExtension

-- DEFINITION: Quantum circuit as ordered gate list Q = G1..Gn
-- STATUS: DEFINITION
def Qseq := QuantumCircuit

-- DEFINITION: Unitary composition U_Q = U_n⋯U_2U_1
-- STATUS: DEFINITION
def U_Q {n} (Q : Qseq) (ψ : QState n) : QState n := applyCircuit Q ψ

-- DEFINITION: Output state |ψ_out> = U_Q|ψ_in>
-- STATUS: DEFINITION
def outputState {n} (Q : Qseq) (psi_in : QState n) : QState n := U_Q Q psi_in

-- DEFINITION: Measurement probabilities from state
-- STATUS: DEFINITION (via measure axiom)
def probs {n} (psi_out : QState n) : List (MeasurementOutcome n) := measure psi_out

-- AXIOM: No guarantee of outcome unless proven
-- STATUS: ASSUMED — measurement is probabilistic; exact prob requires grover_success_probability proof
axiom no_guarantee_without_proof : ∀ {n} (Q : Qseq) (psi_in : QState n) (desired : BitVec n),
  (∃ m ∈ probs (outputState Q psi_in), m.bitstring = desired) → True

-- STATUS NOTE: grover_success_probability (HybridQuantumSAT/Quantum/GroverSearch.lean:76) is
-- CONJECTURE in current formalization (contains sorry); not imported here to avoid unsound upgrade.

end HybridFormalEngine.QuantumCircuitSpec
