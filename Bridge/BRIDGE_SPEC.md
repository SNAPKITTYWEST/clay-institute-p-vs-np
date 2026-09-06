# Bridge Spec — Mathematical Prime Number → Hybrid (OpenQASM)

**Fingerprint:** `SDC-Ω-∂-2026-PVSNP` · **License:** CC BY 4.0 (math) / Sovereign (eng) — `LICENSE`

This document is the **mathematical justification** for the bridge between the
two local P vs NP formalizations in `bobs control repo` and its OpenQASM 3.0
compilation.

---

## 1. Endpoints

### (A) Mathematical track — `formal-conjectures/FormalConjectures/Millenium/PvsNP.lean`

```lean
abbrev DecisionProblem := List Bool → Bool
abbrev ComplexityClass := Set DecisionProblem
def P  : ComplexityClass := { L | IsComputableInPolyTime … L }
def NP : ComplexityClass := { L | ∃ p R poly-time, ∀ x, L x ↔ ∃ w, |w|≤p(|x|) ∧ R(x,w) }
theorem P_ne_NP : P ≠ NP := by sorry  -- research open, AMS 68
theorem P_subset_NP : P ⊆ NP := by sorry
```

- `List Bool` is `Σ*` with `Σ={0,1}` (SharedFoundation/Alphabet.lean: `Bin`).
- `IsComputableInPolyTime` abstracts `δ : C → C` and `T_M(x) ≤ c|x|^k`
  (SharedFoundation/04_Machine, 06_Runtime).

### (B) Hybrid track — `clay-institute-p-vs-np/HybridQuantumSAT/`

```lean
structure Lit where val : ℤ // val ≠ 0
def Clause := Finset Lit
def Fml := Finset Clause
def Asgn := List (ℕ × Bool)
def clause_sat a c := ∃ l ∈ c, lit_val a l = some true
def fml_sat a f := ∀ c ∈ f, clause_sat a c
def reduce : Fml → Fml × Asgn  -- heuristic, placeholder identity
def quantum_search : Fml → QResult  -- Grover oracle, placeholder
```

- `HybridQuantumSAT/Quantum/GroverSearch.lean` refines `quantum_search` into
  `phase_oracle` (`ψ↦ -ψ` on `fml_sat`), `diffusion_operator`
  (`2|ψ⟩⟨ψ|-I`), `grover_search` (`Nat.recOn iterations`).

---

## 2. Prime Gödel Encoding (Gödel Numbering)

**File:** `Bridge/PrimeEncodedSearcher.lean` (copied from `C:/Users/jessi/Desktop/clay-p-vs-np/axiom-engine/PrimeEncodedSearcher.lean`).

First 32 primes (sufficient `n ≤ 32`; extend via sieve for larger `n`):

```
primes = [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97,101,103,107,109,113,127,131]
nthPrime n = primes.getD n 0
```

Assignment `a : Fin n → Bool` ↦ square-free product:

```
π(a) = ∏_{i<n} p_i^{a(i)}          -- a(i)=1 ⇒ include p_i
assignmentToPrimeProduct a = foldl (if a i then acc * p_i else acc) 1
primeProductToAssignment n P i = (P % p_i != 0)
```

**Injectivity** (FTA): `π` injective — distinct `a ≠ b` give distinct
square-free factorizations. Lemma `prime_product_divisible`
(`P % p_i =0 ↔ a i = true`) ⇒ `prime_product_injective`.

**Resource bound:** `P ≤ (p_{n-1})^n`, bits `log₂ P ≤ n·log₂(p_n) = O(n log n)`.
`qubitCount n = n + log₂(P) + 1` (PrimeEncodedSearcher.lean:148).

---

## 3. Clause Satisfaction via Divisibility

```
Literal = pos i | neg i
clauseSatByPrime P [] = false
clauseSatByPrime P (l::ls) =
  let sat = match l with
    | pos i => P % p_i == 0
    | neg i => P % p_i != 0
  in sat || clauseSatByPrime P ls
formulaSatByPrime P cs = cs.all (clauseSatByPrime P)
```

**Correctness:** `clause_prime_correct` —

```
clauseSatByPrime (π(a)) clause = true
  ↔ clause.any (pos i ⇒ a i = true | neg i ⇒ a i = false)
```

which matches `clause_sat` after translating `Finset Lit` (`ℤ` val) to
`Literal` (`Nat` index, `pos` when `val>0` else `neg`).

**Verifier rephrasing** (ComplexityTheory NP):

Take witness `w = binary(P)` where `P = π(a)`. Then
`|w| = O(n log n) ≤ p(|x|)` for `p(n)=n·⌈log₂ n⌉+n` (poly), and
`R(x,w) := formulaSatByPrime P (clauses_of x)` is poly-time
(`Bridge/PrimeToHybrid.qasm` does `m` clause checks, each `P % p_i`
via ancilla QFT division or repeated `cx`).

---

## 4. OpenQASM 3.0 Compilation

**Files:** `Bridge/PrimeToHybrid.qasm` (modular), `PrimeToHybrid_Full.qasm` (n=8 demo).

```
OPENQASM 3.0;
include "stdgates.inc";
qubit[n] vars;      // a_i : 1 iff p_i ∣ P
qubit target;       // phase kickback
qubit[n-1] ancilla;

h vars;                          // superposition over 2^n assignments
gate clause_oracle {              // // Step 2 in PrimeEncodedSearcher.peqs_circuit_source
  x vars[false-positions];       // normalize to |1>
  // MCT detects all-false (= clause unsatisfied)
  cx vars[0], ancilla[0]; ...
  x ancilla[0]; cz ancilla[0], target; x ancilla[0]; // phase flip iff satisfied
  // uncompute
}
gate diffuser {                   // 2|ψ⟩⟨ψ| - I
  h vars; x vars; h vars[n-1]; mcx vars[0:n-1], vars[n-1]; h vars[n-1]; x vars; h vars;
}
```

`PrimeToHybrid.qasm` exposes `clause_sat(P % p_i)` as `cx`+`ancilla` pattern
identical to `GroverSearch.lean:phase_oracle` (`if fml_sat then -ψ x else ψ x`).
`PrimeToHybrid_Full.qasm` instantiates `n=8`, `m=4` (example 3-CNF), runs
`groverIterations n m = ⌊π/4·√(2^n/m)⌋` iterations, then `measure vars`.

**Simulator:** `qasm3.load("Bridge/PrimeToHybrid.qasm")` in Qiskit / `qataaum`.

---

## 5. Bridge Invariant

```
fml_sat a f  ↔  formulaSatByPrime (π(a)) (primeClauses f) = true
             ↔  QASM clause_oracle flips phase on |a⟩
```

Proved (sketch) via `prime_product_divisible` + `clause_prime_correct`;
full proof requires FTA formalization (currently `sorry` in
PrimeEncodedSearcher.lean:59,62 — tracked as hardening obligations
`HARDEN-000003…000005` in `kernel/crystallization-report.pl`).

No bridge axiom decides P vs NP. Status remains `.unresolved`
(`Bridge/PvsNP_Hybrid_Bridge.lean:bridge_status`).

---

## 6. How to Verify

- **Lean (elementary, no build):** inspect `SharedFoundation/*` (13 layers,
  `pVsNP_status = .unresolved`), `HybridQuantumSAT/Basic/*`,
  `Bridge/PvsNP_Hybrid_Bridge.lean` (abstract `EncBridge`), and
  `formal-conjectures/FormalConjectures/Millenium/PvsNP.lean` (Apache 2.0).
- **QASM:** `qasm3` simulator or `sov-kernel-monster/qataaum/examples/` runner.
- **Clay eligibility:** see `LICENSE` §2 and `CLAY_COMPLIANCE.md` — requires
  Qualifying Outlet refereed publication + ≥2 years + general acceptance.

---

*The prime bridge is a representation change, not a complexity change.
Grover remains `O(√(2^n/m))`; the bridge only makes the witness
a square-free integer.*
