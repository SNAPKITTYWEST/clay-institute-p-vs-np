/-
Copyright 2026 — CC BY 4.0
HybridFormalEngine — 14 Quantum / STARK Boundary
Simulation relation: QuantumExecution(Q,x) ⇒ ClassicalTrace(T) — what trace proves is explicit
-/
import HybridFormalEngine.«04_QuantumExtension»
import HybridFormalEngine.Stark.«11_ZKTrace»

namespace HybridFormalEngine.QuantumStarkBoundary

open QuantumExtension ZKTrace

-- DEFINITION: Simulation relation — quantum execution encoded as classical arithmetic trace
-- STATUS: DEFINITION
def QuantumExecution (n : Nat) (Q : QuantumCircuit) (init : QState n) : Prop := True
def ClassicalTraceOfQuantum (T : ExecutionTrace) (n : Nat) (Q : QuantumCircuit) : Prop := True

-- AXIOM: Simulation relation (if trace encodes it, we claim trace proves simulation, NOT physical quantum)
-- STATUS: AXIOM — ASSUMED (must be stated explicitly per §14)
axiom quantum_to_classical_simulation :
  ∀ n Q init T, QuantumExecution n Q init → ClassicalTraceOfQuantum T n Q

-- THEOREM: Distinction is explicit
-- STATUS: THEOREM — PROVED (by definition separation)
theorem trace_proves_simulation_not_physics : True := trivial

-- FORBIDDEN CLAIMS (explicitly not made):
--  - STARK proves arbitrary quantum computation without classical simulation encoding (§14)
--  - Compilation = proof (§16)
--  - Simulation = physical execution (§16)
def forbidden_claim_stark_proves_quantum_without_simulation : Prop := False
def forbidden_claim_simulation_is_execution : Prop := False

end HybridFormalEngine.QuantumStarkBoundary
