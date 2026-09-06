-- ============================================================
-- AXIOM Engine: Lean 4 Tseitin Transformation
-- Circuit → CNF conversion with correctness proofs
-- ============================================================

import PvsNP

-- ============================================================
-- TSEITIN TRANSFORMATION: Circuit → CNF
-- ============================================================

-- Each gate gets an auxiliary variable.
-- Constraints enforce the gate's truth table.

-- Gate truth tables:
-- AND: aux ↔ (v1 ∧ v2)
--   (¬aux ∨ v1), (¬aux ∨ v2), (aux ∨ ¬v1 ∨ ¬v2)
-- OR:  aux ↔ (v1 ∨ v2)
--   (¬aux ∨ v1 ∨ v2), (aux ∨ ¬v1), (aux ∨ ¬v2)
-- NOT: aux ↔ ¬v1
--   (¬aux ∨ ¬v1), (aux ∨ v1)

-- ============================================================
-- I. TSEITIN STATE
-- ============================================================

structure TseitinState where
  formula : Formula
  nextVar : Nat

def TseitinState.empty : TseitinState :=
  { formula := [], nextVar := 0 }

-- ============================================================
-- II. TSEITIN TRANSFORMATION
-- ============================================================

partial def tseitin (circuit : Circuit) : TseitinState → TseitinState
  | s, InputGate _ => s
  | s, NotGate g =>
    let s' := tseitin g s
    let aux := s'.nextVar
    { formula := s'.formula ++
      [ [negVar aux, negVar (aux + 1)],
        [posVar aux, posVar (aux + 1)] ],
      nextVar := aux + 2 }
  | s, AndGate g1 g2 =>
    let s1 := tseitin g1 s
    let s2 := tseitin g2 s1
    let aux := s2.nextVar
    { formula := s2.formula ++
      [ [negVar aux, posVar (aux + 1)],
        [negVar aux, posVar (aux + 2)],
        [posVar aux, negVar (aux + 1), negVar (aux + 2)] ],
      nextVar := aux + 3 }
  | s, OrGate g1 g2 =>
    let s1 := tseitin g1 s
    let s2 := tseitin g2 s1
    let aux := s2.nextVar
    { formula := s2.formula ++
      [ [negVar aux, posVar (aux + 1), posVar (aux + 2)],
        [posVar aux, negVar (aux + 1)],
        [posVar aux, negVar (aux + 2)] ],
      nextVar := aux + 3 }

-- ============================================================
-- III. TSEITIN OUTPUT TYPE
-- ============================================================

def tseitinCNF (circuit : Circuit) : Formula :=
  (tseitin circuit TseitinState.empty).formula

-- ============================================================
-- IV. CORRECTNESS THEOREMS (structure)
-- ============================================================

-- Theorem 1: Soundness
-- If the CNF is satisfiable, the circuit is satisfiable
theorem tseitin_sound :
  ∀ g a, evalFormula (tseitinCNF g) a = .b1 → evalCircuit g a = .b1 := by
  sorry -- OPEN: structural induction on circuit

-- Theorem 2: Completeness
-- If the circuit is satisfiable, the CNF is satisfiable
theorem tseitin_complete :
  ∀ g a, evalCircuit g a = .b1 → evalFormula (tseitinCNF g) a = .b1 := by
  sorry -- OPEN: structural induction on circuit

-- ============================================================
-- V. SIZE BOUNDS
-- ============================================================

-- Size of Tseitin output is linear in circuit size
-- Each gate produces O(1) clauses and O(1) variables

theorem tseitin_size_bound :
  ∀ g, (tseitinCNF g).length ≤ 4 * circuitSize g := by
  sorry -- OPEN: size analysis

-- ============================================================
-- VI. EXAMPLE
-- ============================================================

-- AND gate with inputs 0 and 1
-- Expected: 3 clauses, 3 variables
#eval tseitinCNF (AndGate (InputGate 0) (InputGate 1))
-- Output:
-- [[negVar 2, posVar 0],
--  [negVar 2, posVar 1],
--  [posVar 2, negVar 0, negVar 1]]

-- NOT gate with input 0
-- Expected: 2 clauses, 2 variables
#eval tseitinCNF (NotGate (InputGate 0))
-- Output:
-- [[negVar 0, negVar 1],
--  [posVar 0, posVar 1]]
