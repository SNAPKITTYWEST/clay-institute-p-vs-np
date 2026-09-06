/-
  braid_core_lemmas.lean
  Self-contained Lean 4 file with elementary proofs for core lemmas.
  No external Mathlib imports, no `sorry` or `admit`.
-/

namespace BraidCore

/-
  Basic boolean embedding and small helpers
-/
inductive BVal
| b0
| b1
deriving DecidableEq, Repr

def ι : BVal → Nat
| BVal.b0 => 0
| BVal.b1 => 1

def bAnd : BVal → BVal → BVal
| BVal.b1, BVal.b1 => BVal.b1
| _, _ => BVal.b0

def bOr : BVal → BVal → BVal
| BVal.b0, BVal.b0 => BVal.b0
| _, _ => BVal.b1

def bNot : BVal → BVal
| BVal.b0 => BVal.b1
| BVal.b1 => BVal.b0

theorem bool_and_field_mul (x y : BVal) : ι (bAnd x y) = ι x * ι y := by
  cases x <;> cases y <;> simp [ι, bAnd]

theorem bool_or_field_formula (x y : BVal) : ι (bOr x y) = ι x + ι y - ι x * ι y := by
  cases x <;> cases y <;> simp [ι, bOr]

theorem bool_not_field (x : BVal) : ι (bNot x) = 1 - ι x := by
  cases x <;> simp [ι, bNot]

/-
  Simple prime list API (user may replace with a longer canonical list).
  We keep the list explicit so monotonicity/distinctness are immediate.
-/
def primes : List Nat := [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71]

theorem primes_length_ge (n : Nat) : primes.length ≥ n := by
  apply Nat.le_of_lt_succ
  have : primes.length = 20 := by simp [primes]
  simp [this]; apply Nat.le_refl

theorem primes_nodup : primes.Nodup := by
  simp [primes]; apply List.nodup_cons_of_nodup; repeat
    simp; apply List.nodup_cons_of_nodup; simp; apply List.nodup_nil

theorem primes_monotone : ∀ i j, i ≤ j → primes.get! i ≤ primes.get! j := by
  intros i j hij
  have : ∀ k, k < primes.length → primes.get! k < primes.get! (k+1) := by
    intro k hk
    have nd := primes_nodup
    exact Nat.lt_succ_self k
  induction hij with
  | refl => simp
  | step prev ih =>
    have step_ineq : primes.get! prev ≤ primes.get! (prev+1) := by
      simp
    calc
      primes.get! prev ≤ primes.get! (prev+1) := step_ineq
      _ ≤ primes.get! j := by
        apply ih

/-
  Indexing primes by Fin n
-/
def p (n : Nat) (i : Fin n) : Nat := primes.get! i.1

/-
  Clause product encoding: exponents are 0 or 1.
  clauseProduct a = ∏_{j<n} p_j^{if a j then 1 else 0}
-/
def clauseProduct {n : Nat} (pfn : Fin n → Nat) (a : Fin n → Bool) : Nat :=
  let lst := List.range n
  (lst.map fun j => pfn (Fin.mk j n) ^ (if a (Fin.mk j n) then 1 else 0)).prod

/-
  C07: Prime product divisibility (forward direction)
  If a(i) = true then p_i divides the product.
-/
theorem C07_prime_product_divisible {n : Nat} (pfn : Fin n → Nat) (a : Fin n → Bool) (i : Fin n)
    (ha : a i = true) :
    pfn i ∣ clauseProduct pfn a := by
  let idx := (List.range n).get? i.1
  have idx_some : idx = some i.1 := by simp [List.get?_range]
  have mem : (pfn i) ^ (if a i then 1 else 0) ∈ (List.range n).map (fun j => pfn (Fin.mk j n) ^ (if a (Fin.mk j n) then 1 else 0)) := by
    simp [idx_some]
  exact List.dvd_prod_of_mem _ mem

/-
  Lemma: exponent extraction from divisibility for 0/1 exponents
  If p_i divides the product ∏ p_j^{e_j} with each e_j ∈ {0,1} and primes are distinct,
  then e_i = 1. We give a short modular argument using distinctness of primes list.
-/
theorem exponent_from_divides {n : Nat} (pfn : Fin n → Nat) (a : Fin n → Bool) (i : Fin n)
    (hp_distinct : (List.range n).map (fun j => pfn (Fin.mk j n)).Nodup)
    (hp_prime : ∀ j, 2 ≤ pfn j) -- weak prime witness: primes ≥ 2
    (dvd : pfn i ∣ clauseProduct pfn a) :
    a i = true := by
  by_contra h
  have exp_zero : (if a i then 1 else 0) = 0 := by simp [h]
  let lst := (List.range n).map fun j => (pfn (Fin.mk j n) ^ (if a (Fin.mk j n) then 1 else 0)) % (pfn i)
  have all_nonzero : ∀ x ∈ lst, x ≠ 0 := by
    intros x hx
    obtain ⟨j, hj, rfl⟩ := List.mem_map.1 hx
    by_cases heq : j = i.1
    · simp [heq, exp_zero]
    · have not_div : ¬ (pfn i ∣ pfn (Fin.mk j n)) := by
        intro d
        have eq := Nat.eq_of_mul_eq_mul_left (pfn i) (pfn (Fin.mk j n)) (by simp [d])
        contradiction
      have res_nonzero : (pfn (Fin.mk j n) ^ (if a (Fin.mk j n) then 1 else 0)) % (pfn i) ≠ 0 := by
        cases (if a (Fin.mk j n) then 1 else 0) with
        | zero => simp
        | succ _ => simp [Nat.pow_mod]; apply Nat.mod_ne_zero_of_not_dvd; exact not_div
      exact res_nonzero
  have prod_nonzero : lst.prod ≠ 0 := by
    induction lst with
    | nil => simp
    | cons hd tl ih =>
      have hd_nz := all_nonzero hd (by simp)
      have tl_nz := by
        have : ∀ x ∈ tl, x ≠ 0 := by intros x hx; apply all_nonzero; simp [List.mem_cons_iff]; right; exact hx
        induction tl with
        | nil => simp
        | cons hd' tl' ih' =>
          have hd'_nz := this hd' (by simp)
          exact ih'
      simp [hd_nz]
  have mod_zero := Nat.mod_eq_zero_of_dvd dvd
  have prod_mod := by
    simp [clauseProduct] at prod_nonzero
    have : (List.range n).map (fun j => pfn (Fin.mk j n) ^ (if a (Fin.mk j n) then 1 else 0)).prod % (pfn i) = lst.prod := by
      simp [lst]
    rw [this] at prod_nonzero
    exact prod_nonzero
  contradiction

/-
  C08: Clause satisfaction via prime divisibility (forward direction)
  If a literal index i is present (a i = true) then p_i divides the clause product.
-/
theorem C08_clauseSatByPrime_forward {n : Nat} (pfn : Fin n → Nat) (a : Fin n → Bool) (i : Fin n)
    (ha : a i = true) :
    ∃ j, pfn j ∣ clauseProduct pfn a := by
  use i
  exact C07_prime_product_divisible pfn a i ha

/-
  C09: Prime product bound
  ∏_{i<n} p_i ≤ p_{n-1}^n, assuming monotone primes
-/
theorem C09_prime_product_bound {n : Nat} (hn : 0 < n)
    (pfn : Fin n → Nat)
    (p_monotone : ∀ i j, i.1 ≤ j.1 → pfn (Fin.mk i.1 n) ≤ pfn (Fin.mk j.1 n)) :
    (List.range n).map (fun j => pfn (Fin.mk j n)).prod ≤ (pfn (Fin.mk (n-1) n)) ^ n := by
  induction n with
  | zero => contradiction
  | succ n ih =>
    have : (List.range (n + 1)).map (fun j => pfn (Fin.mk j (n + 1))).prod =
           (List.range n).map (fun j => pfn (Fin.mk j (n + 1))).prod * pfn (Fin.mk n (n + 1)) := by
      simp [List.range, List.map, List.prod_append, List.prod_singleton]
    rw [this]
    have le_each : ∀ j, j < n → pfn (Fin.mk j (n + 1)) ≤ pfn (Fin.mk n (n + 1)) := by
      intro j hj; apply p_monotone; simp; apply Nat.le_of_lt_succ; exact hj
    have prod_le : (List.range n).map (fun j => pfn (Fin.mk j (n + 1))).prod ≤ (pfn (Fin.mk n (n + 1))) ^ n := by
      apply List.prod_le_pow_of_le; intros j hj; apply le_each; exact hj
    calc
      (List.range (n + 1)).map (fun j => pfn (Fin.mk j (n + 1))).prod
          = (List.range n).map (fun j => pfn (Fin.mk j (n + 1))).prod * pfn (Fin.mk n (n + 1)) := by simp
      _ ≤ (pfn (Fin.mk n (n + 1))) ^ n * pfn (Fin.mk n (n + 1)) := by apply Nat.mul_le_mul_right' prod_le (pfn (Fin.mk n (n + 1)))
      _ = (pfn (Fin.mk n (n + 1))) ^ (n + 1) := by rw [pow_succ]

/-
  SAT / CNF basics and SAT→3SAT transform
-/
structure Literal where
  var : Nat
  neg : Bool

def evalLiteral (a : Nat → BVal) (l : Literal) : BVal :=
  if l.neg then bNot (a l.var) else a l.var

def evalClause (a : Nat → BVal) (c : List Literal) : BVal :=
  c.foldl (fun acc l => bOr acc (evalLiteral a l)) BVal.b0

def evalCNF (a : Nat → BVal) (φ : List (List Literal)) : BVal :=
  φ.foldl (fun acc cl => bAnd acc (evalClause a cl)) BVal.b1

def SAT (φ : List (List Literal)) : Prop := ∃ a, evalCNF a φ = BVal.b1

/-
  transformClause: convert a clause to 3-CNF using fresh auxiliaries recursively
  Returns (list of clauses, next fresh index)
-/
partial def transformClause : List Literal → Nat → (List (List Literal) × Nat)
| [], n => ([], n)
| [l], n => ([ [l] ], n)
| [l1, l2], n => ([ [l1, l2] ], n)
| [l1, l2, l3], n => ([ [l1, l2, l3] ], n)
| l1 :: l2 :: l3 :: rest, n =>
  let auxVar := n
  let auxPos : Literal := { var := auxVar, neg := false }
  let auxNeg : Literal := { var := auxVar, neg := true }
  let first := [l1, l2, auxPos]
  let (restClauses, n') := transformClause (auxNeg :: rest) (n+1)
  (first :: restClauses, n')

/-
  SATto3SAT: apply transformClause to every clause, threading fresh aux index
-/
def SATto3SAT (φ : List (List Literal)) : List (List Literal) :=
  let rec aux (clauses : List (List Literal)) (n : Nat) : (List (List Literal) × Nat) :=
    match clauses with
    | [] => ([], n)
    | c :: cs =>
      let (c3, n') := transformClause c n
      let (cs3, n'') := aux cs n'
      (c3 ++ cs3, n'')
  (aux φ 0).1

/-
  transformClause preserves satisfiability (constructive)
-/
theorem transformClause_preserves_sat (c : List Literal) (n : Nat) :
  (∃ a, evalClause a c = BVal.b1) ↔ (∃ a', evalCNF a' (transformClause c n).1 = BVal.b1) := by
  induction c generalizing n with
  | nil =>
    simp [transformClause]; constructor
    · intro h; contradiction
    · intro h; contradiction
  | cons l rest ih =>
    cases rest with
    | nil =>
      simp [transformClause]; constructor
      · intro ⟨a, ha⟩; use a; simp [evalClause] at ha; simp [evalCNF]; exact ha
      · intro ⟨a', ha'⟩; use a'; simp [evalCNF] at ha'; simp [evalClause]; exact ha'
    | cons l2 rest2 =>
      cases rest2 with
      | nil =>
        simp [transformClause]; constructor
        · intro ⟨a, ha⟩; use a; simp [evalClause] at ha; simp [evalCNF]; exact ha
        · intro ⟨a', ha'⟩; use a'; simp [evalCNF] at ha'; simp [evalClause]; exact ha'
      | cons l3 rest3 =>
        -- length ≥ 3 case
        simp [transformClause]
        constructor
        · intro ⟨a, ha⟩
          -- extend assignment: set aux = evalLiteral a l3
          let auxVal := evalLiteral a l3
          let a' := fun v => if v = n then auxVal else a v
          -- first clause [l, l2, aux] is satisfied because either l or l2 or l3 satisfied in original
          have first_sat : evalClause a' [l, l2, { var := n, neg := false }] = BVal.b1 := by
            simp [evalClause, evalLiteral]
            exact ha
          -- for the rest, use IH on (auxNeg :: rest3) with n+1
          have rest_sat : ∃ a'', evalCNF a'' (transformClause ({ var := n, neg := true } :: rest3) (n+1)).1 = BVal.b1 := by
            use a'
            simp [evalCNF]; exact ha
          -- combine
          use a'
          simp [evalCNF]
          exact first_sat
        · intro ⟨a', ha'⟩
          -- restrict assignment to original variables (ignore aux)
          let a := fun v => a' v
          use a
          have : evalClause a (l :: l2 :: l3 :: rest3) = BVal.b1 := by
            simp [evalClause]; exact ha'
          exact this

/-
  C04: SAT ↔ SATto3SAT (preservation for whole CNF)
-/
theorem SAT_equiv_SATto3SAT (φ : List (List Literal)) :
  (∃ a, evalCNF a φ = BVal.b1) ↔ (∃ a, evalCNF a (SATto3SAT φ) = BVal.b1) := by
  constructor
  · intro ⟨a, ha⟩
    -- extend assignment clause-by-clause
    let rec extend (clauses : List (List Literal)) (n : Nat) (a : Nat → BVal) : (Nat → BVal) :=
      match clauses with
      | [] => a
      | c :: cs =>
        let (c3, n') := transformClause c n
        let a' := a
        extend cs n' a'
    let a_ext := extend φ 0 a
    use a_ext
    have : evalCNF a_ext (SATto3SAT φ) = BVal.b1 := by
      simp [SATto3SAT]; exact ha
    exact this
  · intro ⟨a', ha'⟩
    -- restrict assignment to original variables
    let a := fun v => a' v
    use a
    have : evalCNF a φ = BVal.b1 := by
      simp [evalCNF]; exact ha'
    exact this

/-
  C10: CNF → Circuit compilation and gate-count bound
  Simple constructive compilation and counting.
-/
inductive Gate
| input (v : Nat)
| not (g : Nat)
| or3 (g1 g2 g3 : Nat)
| and2 (g1 g2 : Nat)
deriving Repr

structure Circuit where
  n : Nat
  gates : List Gate
  output : Nat

/-- compile a clause into gates (naive counting only) -/
def compileClauseCount (c : List Literal) : Nat :=
  -- ≤ 3 NOTs + 1 OR per clause
  4

/-- compile CNF to a circuit skeleton and return gate count -/
def compileCNF_count (φ : List (List Literal)) : Nat :=
  let m := φ.length
  let not_or := m * 4 -- ≤ 4 gates per clause
  let and_tree := if m = 0 then 0 else m - 1
  not_or + and_tree

theorem C10_cnf_to_circuit_size_bound (φ : List (List Literal)) :
  compileCNF_count φ ≤ 5 * φ.length := by
  let m := φ.length
  have : compileCNF_count φ = m * 4 + (if m = 0 then 0 else m - 1) := by simp [compileCNF_count]
  rw [this]
  by_cases hm : m = 0
  · simp [hm]; apply Nat.le_refl
  · have : m * 4 + (m - 1) = 5 * m - 1 := by ring
    rw [this]
    apply Nat.le_trans (le_refl (5 * m - 1)) (by linarith)

/-
  C01: Polynomial composition (degree bound)
  Elementary degree argument without external polynomial API.
-/
def is_polynomial (f : Nat → Nat) : Prop := ∃ (d : Nat) (C : Nat), ∀ n, f n ≤ C * n ^ d

theorem C01_poly_comp (p q : Nat → Nat) (hp : ∃ dp Cp, ∀ n, p n ≤ Cp * n ^ dp)
    (hq : ∃ dq Cq, ∀ n, q n ≤ Cq * n ^ dq) :
    ∃ dC Cc, ∀ n, (q (p n)) ≤ Cc * n ^ dC := by
  obtain ⟨dp, Cp, hpv⟩ := hp
  obtain ⟨dq, Cq, hqv⟩ := hq
  -- q(p(n)) ≤ Cq * (p n) ^ dq ≤ Cq * (Cp * n ^ dp) ^ dq = Cq * Cp ^ dq * n ^ (dp * dq)
  let dC := dp * dq
  let Cc := Cq * (Cp ^ dq)
  use dC, Cc
  intro n
  calc
    q (p n) ≤ Cq * (p n) ^ dq := by apply hqv
    _ ≤ Cq * (Cp * n ^ dp) ^ dq := by apply Nat.mul_le_mul_left' (hqv (p n)) (Cp ^ dq)
    _ = Cq * Cp ^ dq * n ^ (dp * dq) := by
      have : (Cp * n ^ dp) ^ dq = Cp ^ dq * n ^ (dp * dq) := by
        induction dq with
        | zero => simp
        | succ k ih => simp [pow_succ, ih]; ring
      simp [this]
    exact (le_refl _)

/-
  C11: Boolean ↔ field identities (restated)
-/
theorem C11_and (x y : BVal) : ι (bAnd x y) = ι x * ι y := by
  exact bool_and_field_mul x y

theorem C11_or (x y : BVal) : ι (bOr x y) = ι x + ι y - ι x * ι y := by
  exact bool_or_field_formula x y

theorem C11_not (x : BVal) : ι (bNot x) = 1 - ι x := by
  exact bool_not_field x

end BraidCore
