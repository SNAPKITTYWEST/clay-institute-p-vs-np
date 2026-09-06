/-
Copyright 2026 Ahmad Ali Parr + Jessica Westerhoff
Shared Foundation Layer 12: Boolean Formulas
  B={0,1}, vars v0..v_{n-1}, assignment a:{0..n-1}→B, eval(φ,a)∈B, SAT(φ) iff ∃a eval=1
-/

abbrev B := Bool
abbrev Var (n : Nat) := Fin n
def Assignment (n : Nat) := Fin n → B

inductive Lit (n : Nat) where
  | pos : Var n → Lit n
  | neg : Var n → Lit n
  deriving DecidableEq, Repr

def Clause (n : Nat) := List (Lit n)

inductive Formula (n : Nat) where
  | cnf : List (Clause n) → Formula n

def evalLit {n : Nat} (a : Assignment n) : Lit n → B
  | .pos v => a v
  | .neg v => !a v

def evalClause {n : Nat} (a : Assignment n) (c : Clause n) : B :=
  c.foldl (fun acc l => acc || evalLit a l) false

def evalFormula {n : Nat} (a : Assignment n) : Formula n → B
  | .cnf cs => cs.foldl (fun acc c => acc && evalClause a c) true

def SAT {n : Nat} (phi : Formula n) : Prop :=
  ∃ a : Assignment n, evalFormula a phi = true
