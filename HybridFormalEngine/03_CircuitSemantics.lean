/-
Copyright 2026 Ahmad Ali Parr + Jessica Westerhoff — CC BY 4.0
HybridFormalEngine — 03 Circuit Semantics
C=(W,G,I,O), Eval_G, Eval_C, SAT↔circuit correspondence
-/
import HybridFormalEngine.«01_AxiomaticFoundation»
import HybridFormalEngine.«02_ClassicalSAT»

namespace HybridFormalEngine.CircuitSemantics

open AxiomaticFoundation ClassicalSAT

-- DEFINITION: Circuit as DAG structure
-- STATUS: DEFINITION
structure Circuit where
  W : FiniteSet Wire
  G : List Gate
  I : List Wire  -- input wires
  O : List Wire  -- output wires (for SAT, single output)
  dag : True  -- ASSUMED: acyclicity proof obligation (explicit)
  io_subset : True -- ASSUMED: I,O ⊆ W

-- DEFINITION: Gate evaluation
-- STATUS: DEFINITION
def evalGateKind : GateKind → List BVal → Option BVal
  | .gNot, [a] => some (bNot a)
  | .gAnd, [a,b] => some (bAnd a b)
  | .gOr,  [a,b] => some (bOr a b)
  | .gXor, [a,b] => some (bXor a b)
  | .gNand,[a,b] => some (bNand a b)
  | .gNor, [a,b] => some (bNor a b)
  | .gInput, _ => none  -- input driven externally
  | _, _ => none

-- DEFINITION: Wire valuation
-- STATUS: DEFINITION
def Valuation := Wire → Option BVal

-- DEFINITION: Single gate step
-- STATUS: DEFINITION
def evalGate (g : Gate) (val : Valuation) : Option BVal :=
  let ins := g.inputs.map (val ·)
  if ins.any (· == none) then none
  else evalGateKind g.kind (ins.filterMap id)

-- DEFINITION: Full circuit evaluation (iterative propagation, assumes topological order)
-- STATUS: ASSUMED (requires DAG topological order; axiomatized to avoid sorry)
axiom evalCircuit : Circuit → List (Wire × BVal) → Valuation

-- CONJECTURE: Correspondence between CNF eval and circuit eval
-- STATUS: CONJECTURE (requires compilation φ ↦ C correct)
axiom cnf_to_circuit : CNF → Circuit

-- CONJECTURE: SAT(φ) ↔ ∃ x. Eval_C(x)=1 for corresponding circuit
-- STATUS: CONJECTURE (compilation correctness)
axiom sat_iff_circuit_exists :
  ∀ φ, SAT φ ↔ ∃ (input : List (Wire × BVal)),
    let C := cnf_to_circuit φ
    ∃ w ∈ C.O, evalCircuit C input w = some .b1

-- DERIVED LEMMA: If correspondence holds, 3SAT inherits it
-- STATUS: DERIVED LEMMA (from sat_iff_circuit_exists)
theorem threeSAT_iff_circuit_of_sat_iff :
  (∀ φ, SAT φ ↔ ∃ input, ∃ w ∈ (cnf_to_circuit φ).O, evalCircuit (cnf_to_circuit φ) input w = some .b1)
  → ∀ φ, Is3CNF φ → (ThreeSAT φ ↔ ∃ input, ∃ w ∈ (cnf_to_circuit φ).O, evalCircuit (cnf_to_circuit φ) input w = some .b1) :=
  fun h φ h3 => ⟨fun ⟨_, hs⟩ => (h φ).mp hs, fun he => ⟨h3, (h φ).mpr he⟩⟩

end HybridFormalEngine.CircuitSemantics
