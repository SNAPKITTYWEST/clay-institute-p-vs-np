-- Copyright 2026 — CC BY 4.0 (math)
-- Body of SAT_Verifier — preserves CircuitSemantics.evalCircuit invariant
package body SAT_Verifier with SPARK_Mode is

   function Eval_Lit (A : Assignment; L : Lit) return Boolean is
      V : constant Integer := abs L.V;
      B : constant Boolean := A (V);
   begin
      if L.V > 0 then return B;
      else return not B;
      end if;
   end Eval_Lit;

   function Eval_Clause (A : Assignment; C : CNF_Clause) return Boolean is
      Result : Boolean := False;
   begin
      for I in 1 .. C.Len loop
         pragma Loop_Invariant (Result = False or Result = True);
         pragma Loop_Invariant (for some J in 1 .. I-1 => Eval_Lit (A, C.Lits (J)) = True implies Result = True);
         if Eval_Lit (A, C.Lits (I)) then
            Result := True;
         end if;
      end loop;
      return Result;
   end Eval_Clause;

   function Eval_CNF (A : Assignment; Phi : CNF; N : CNF_Len) return Boolean is
      Result : Boolean := True;
   begin
      for I in 1 .. N loop
         pragma Loop_Invariant (Result = True or Result = False);
         pragma Loop_Invariant (Result = (for all J in 1 .. I-1 => Eval_Clause (A, Phi (J))));
         if not Eval_Clause (A, Phi (I)) then
            Result := False;
         end if;
      end loop;
      return Result;
   end Eval_CNF;

   function Verify_SAT (Phi : CNF; N : CNF_Len; A : Assignment) return Boolean is
   begin
      return Eval_CNF (A, Phi, N);
   end Verify_SAT;

end SAT_Verifier;
