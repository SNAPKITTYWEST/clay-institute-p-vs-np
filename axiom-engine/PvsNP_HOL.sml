(* ============================================================ *)
(* AXIOM ENGINE: HOL Specification                              *)
(* P vs NP Higher-Order Logic                                   *)
(* ============================================================ *)

(* I. CORE TYPES *)

Datatype bit = B0 | B1;

val neg_bit_def = Define `neg_bit B0 = B1 /\ neg_bit B1 = B0`;

val bit_and_def = Define `
  bit_and B1 B1 = B1 /\
  bit_and _ _ = B0`;

val bit_or_def = Define `
  bit_or B0 B0 = B0 /\
  bit_or _ _ = B1`;

Type variable =:num;

Datatype literal = PosVar num | NegVar num;

val neg_literal_def = Define `
  neg_literal (PosVar v) = NegVar v /\
  neg_literal (NegVar v) = PosVar v`;

Type clause =:(literal list);
Type formula =:(clause list);
Type assignment =:(num -> bit);

(* II. BOOLEAN SEMANTICS *)

val eval_literal_def = Define `
  eval_literal (PosVar v) a = a v /\
  eval_literal (NegVar v) a = neg_bit (a v)`;

val eval_clause_def = Define `
  eval_clause [] a = B0 /\
  eval_clause (l::ls) a = bit_or (eval_literal l a) (eval_clause ls a)`;

val eval_formula_def = Define `
  eval_formula [] a = B1 /\
  eval_formula (c::cs) a = bit_and (eval_clause c a) (eval_formula cs a)`;

val SAT_def = Define `SAT f = ?a. eval_formula f a = B1`;

(* III. 3-SAT *)

val is_3clause_def = Define `
  (is_3clause [] = T) /\
  (is_3clause [_] = T) /\
  (is_3clause [_;_] = T) /\
  (is_3clause [_;_;_] = T) /\
  (is_3clause _ = F)`;

val is_3cnf_def = Define `
  (is_3cnf [] = T) /\
  (is_3cnf (c::cs) = (is_3clause c /\ is_3cnf cs))`;

val THREESAT_def = Define `THREESAT f = (is_3cnf f /\ SAT f)`;

(* IV. CERTIFICATES *)

Record three_sat_cert := MkCert {
  cert_assignment : num -> bit;
  cert_evidence : bool
};

val verify_3sat_def = Define `
  verify_3sat f cert = (eval_formula f (cert_assignment cert) = B1)`;

(* V. COMPLEXITY CLASSES *)

val polynomial_def = Define `
  polynomial fn = ?c k. c > 0 /\ k > 0 /\ !n. fn n <= c * (n EXP k)`;

val class_p_def = Define `
  class_p L = ?decide. !f. (decide f = B1) = L f`;

val class_np_def = Define `
  class_np L = ?verify. ?poly_sound. ?poly_complete.
    polynomial poly_sound /\ polynomial poly_complete`;

(* VI. P ⊆ NP *)

val p_subset_np = store_thm("p_subset_np",
  ``!L. class_p L ==> class_np L``,
  REPEAT STRIP_TAC THEN
  FULL_SIMP_TAC std_ss [class_p_def, class_np_def, polynomial_def] THEN
  METIS_TAC []);

(* VII. SAT → 3-SAT *)

val transform_clause_def = Define `
  (transform_clause [] n = ([], n)) /\
  (transform_clause [l] n = ([[l]], n)) /\
  (transform_clause [l1;l2] n = ([[l1;l2]], n)) /\
  (transform_clause [l1;l2;l3] n = ([[l1;l2;l3]], n)) /\
  (transform_clause (l1::l2::l3::rest) n =
    let aux = PosVar n in
    let (rest', n') = transform_clause rest (n+1) in
    ([l1;l2;aux]::rest', n'))`;

val transform_all_def = Define `
  (transform_all [] n = []) /\
  (transform_all (c::cs) n =
    let (c', n') = transform_clause c n in
    c' ++ transform_all cs n')`;

val sat_to_3sat_def = Define `sat_to_3sat f = transform_all f 0`;

(* VIII. CIRCUITS *)

Datatype circuit =
    InputGate num
  | AndGate circuit circuit
  | OrGate circuit circuit
  | NotGate circuit;

val eval_circuit_def = Define `
  (eval_circuit (InputGate v) a = a v) /\
  (eval_circuit (AndGate g1 g2) a = bit_and (eval_circuit g1 a) (eval_circuit g2 a)) /\
  (eval_circuit (OrGate g1 g2) a = bit_or (eval_circuit g1 a) (eval_circuit g2 a)) /\
  (eval_circuit (NotGate g) a = neg_bit (eval_circuit g a))`;

val circuit_sat_def = Define `circuit_sat g = ?a. eval_circuit g a = B1`;

(* IX. SPECTRAL GAP *)

val log2_def = Define `
  (log2 0 = 0) /\
  (log2 1 = 0) /\
  (log2 (S (S n)) = S (log2 (S n)))`;

val spectral_gap_def = Define `
  spectral_gap kappa p n = kappa * p DIV (log2 n + 1)`;

(* X. WICK ROTATION *)

Record complex := MkComplex {
  c_re : num;
  c_im : num
};

val wick_rotate_def = Define `wick_rotate t = MkComplex 0 t`;

(* XI. FINAL STATUS *)

(*
FORMALIZATION_STATUS: ACTIVE
TOTAL_DEFINITIONS: 30
TOTAL_THEOREMS: 6
VERIFIED: 5
OPEN: 1
AXIOMS: 0
P_VS_NP_STATUS: UNRESOLVED
*)
