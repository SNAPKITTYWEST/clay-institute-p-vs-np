/-
Copyright 2026 Ahmad Ali Parr + Jessica Westerhoff — CC BY 4.0
HybridFormalEngine — 05 Hybrid Quantum-Classical Circuit
H=(C,Q,M,R): classical preprocess → quantum → measurement → postprocess
-/
import HybridFormalEngine.«03_CircuitSemantics»
import HybridFormalEngine.«04_QuantumExtension»

namespace HybridFormalEngine.HybridCircuit

open CircuitSemantics QuantumExtension AxiomaticFoundation

-- DEFINITION: Hybrid computation
-- STATUS: DEFINITION
structure HybridCircuit where
  C : Circuit                    -- classical circuit (preprocess)
  Q : QuantumCircuit             -- quantum circuit
  M : True  -- placeholder for Measurement interface type (ASSUMED distinct)
  R : True  -- placeholder for classical post-processing (ASSUMED)

-- DEFINITION: Execution model pipeline
-- STATUS: DEFINITION (interface types ASSUMED)
axiom ClassicalPreprocess : List (Wire × BVal) → List (Wire × BVal)
axiom MeasurementInterface : {n : Nat} → QState n → List BVal  -- collapses QState to bits
axiom ClassicalPostprocess : List BVal → Option BVal  -- SAT decision bit

-- DEFINITION: Hybrid execution as composition
-- STATUS: DEFINITION
def hybridExecute (H : HybridCircuit) (input : List (Wire × BVal)) (n : Nat) (qInit : QState n) : Option BVal :=
  let pre := ClassicalPreprocess input
  let ψ' := applyCircuit H.Q qInit
  let measuredBits := MeasurementInterface ψ'
  ClassicalPostprocess measuredBits

-- ASSUMED: Interface between classical and quantum portions is well-typed
-- STATUS: ASSUMED (requires BitVec ↦ QState encoding proof)
axiom interface_well_typed : ∀ H, True

-- DERIVED LEMMA: Hybrid execution is probabilistic due to measurement
-- STATUS: DERIVED LEMMA (from QuantumExtension.measure)
theorem hybrid_is_probabilistic : quantumMeasurementIsProbabilistic := separation.2

end HybridFormalEngine.HybridCircuit
