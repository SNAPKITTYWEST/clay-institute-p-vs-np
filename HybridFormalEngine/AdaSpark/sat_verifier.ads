-- Copyright 2026 Ahmad Ali Parr + Jessica Westerhoff — CC BY 4.0 (math) / Sovereign (eng)
-- HybridFormalEngine — 08 Ada/SPARK Classical Verification
-- Translates ClassicalSAT.evalCNF + VerificationPath.Verify_SAT into SPARK contracts
-- Fingerprint: SDC-Ω-∂-2026-PVSNP

package SAT_Verifier with SPARK_Mode is

   Max_Vars    : constant := 256;
   Max_Clauses : constant := 1024;
   Max_Lits    : constant := 3; -- 3-CNF; general CNF extends via range check

   subtype Var_Index is Integer range 0 .. Max_Vars - 1;
   subtype Lit_Val is Integer range -Max_Vars .. Max_Vars;
   pragma Assert (Lit_Val'First /= 0);

   type Lit is record
      V : Lit_Val;
   end record;

   type Clause is array (1 .. Max_Lits) of Lit;
   type Clause_Len is range 0 .. Max_Lits;

   type CNF_Clause is record
      Lits : Clause;
      Len  : Clause_Len;
   end record;

   type CNF is array (1 .. Max_Clauses) of CNF_Clause;
   type CNF_Len is range 0 .. Max_Clauses;

   type Assignment is array (Var_Index) of Boolean;

   -- Precondition predicates (mathematical validity)
   function Is_Valid_Lit (L : Lit) return Boolean is
     (L.V /= 0 and abs L.V < Max_Vars);

   function Is_Valid_Clause (C : CNF_Clause) return Boolean is
     (for all I in 1 .. C.Len => Is_Valid_Lit (C.Lits (I)));

   function Is_Valid_CNF (Phi : CNF; N : CNF_Len) return Boolean is
     (for all I in 1 .. N => Is_Valid_Clause (Phi (I)));

   function Is_Valid_Assignment (A : Assignment) return Boolean is (True);
   -- Assignment always valid; partial assignment modeled via separate Present array

   -- Functional correctness: Eval
   function Eval_Lit (A : Assignment; L : Lit) return Boolean
     with Pre => Is_Valid_Lit (L);

   function Eval_Clause (A : Assignment; C : CNF_Clause) return Boolean
     with Pre => Is_Valid_Clause (C);

   function Eval_CNF (A : Assignment; Phi : CNF; N : CNF_Len) return Boolean
     with Pre => Is_Valid_CNF (Phi, N);

   -- Authoritative verifier: Verify_SAT(φ,a)=1 ↔ Eval(φ,a)=1
   function Verify_SAT (Phi : CNF; N : CNF_Len; A : Assignment) return Boolean
     with
       Pre  => Is_Valid_CNF (Phi, N),
       Post => Verify_SAT'Result = Eval_CNF (A, Phi, N);
   -- Proof obligation: verifier correctness = eval correctness (07_VerificationPath.verify_correct)

   -- Range / overflow reasoning
   -- All Lit_Val abs < Max_Vars ensures no overflow on array indexing
   -- Loop invariants required for iterative Eval_CNF implementation:
   --   for I in 1..N: invariant (Result = Eval of Phi[1..I-1])

end SAT_Verifier;
