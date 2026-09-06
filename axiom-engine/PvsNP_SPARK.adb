-- ============================================================
-- AXIOM Engine: SPARK Ada Body
-- ============================================================

package body PvsNP_SPARK
  with SPARK_Mode => On
is

   function Neg_Bit (B : Bit_Type) return Bit_Type is
   begin
      if B = B0 then return B1;
      else return B0;
      end if;
   end Neg_Bit;

   function Bit_And (A, B : Bit_Type) return Bit_Type is
   begin
      if A = B1 and B = B1 then return B1;
      else return B0;
      end if;
   end Bit_And;

   function Bit_Or (A, B : Bit_Type) return Bit_Type is
   begin
      if A = B0 and B = B0 then return B0;
      else return B1;
      end if;
   end Bit_Or;

   function Eval_Literal (Lit : Literal_Record;
                          Assign : Assignment_Type) return Bit_Type is
   begin
      if Lit.Kind = PosVar then
         return Assign (Lit.Var);
      else
         return Neg_Bit (Assign (Lit.Var));
      end if;
   end Eval_Literal;

   function Eval_Clause (Clause : Clause_Type;
                         Assign : Assignment_Type) return Bit_Type is
      Result : Bit_Type := B0;
   begin
      for I in Clause'Range loop
         Result := Bit_Or (Result, Eval_Literal (Clause (I), Assign));
         exit when Result = B1;
      end loop;
      return Result;
   end Eval_Clause;

   function Eval_Formula (Formula : Formula_Type;
                          Assign : Assignment_Type) return Bit_Type is
      Result : Bit_Type := B1;
   begin
      for I in Formula'Range loop
         Result := Bit_And (Result, Eval_Clause (Formula (I), Assign));
         exit when Result = B0;
      end loop;
      return Result;
   end Eval_Formula;

   function Is_3Clause (Clause : Clause_Type) return Boolean is
   begin
      return Clause'Length <= 3;
   end Is_3Clause;

   function Is_3CNF (Formula : Formula_Type) return Boolean is
   begin
      for I in Formula'Range loop
         if not Is_3Clause (Formula (I)) then
            return False;
         end if;
      end loop;
      return True;
   end Is_3CNF;

   function Verify_3SAT (Formula : Formula_Type;
                         Assign  : Assignment_Type) return Boolean is
   begin
      return Is_3CNF (Formula) and then
             Eval_Formula (Formula, Assign) = B1;
   end Verify_3SAT;

   function Log2 (N : Natural) return Natural is
      Result : Natural := 0;
      Temp   : Natural := N;
   begin
      while Temp > 1 loop
         Temp := Temp / 2;
         Result := Result + 1;
      end loop;
      return Result;
   end Log2;

   function Spectral_Gap (Kappa, P, N : Natural) return Natural is
   begin
      return Kappa * P / (Log2 (N) + 1);
   end Spectral_Gap;

   function Mixing_Time (Gamma : Natural) return Natural is
   begin
      return 1 / Gamma + 1;
   end Mixing_Time;

   function Wick_Rotate (T : Float) return Complex_Type is
   begin
      return (Re => 0.0, Im => T);
   end Wick_Rotate;

   function Euclidean_Norm (C : Complex_Type) return Float is
   begin
      return C.Re * C.Re + C.Im * C.Im;
   end Euclidean_Norm;

   function Valid_Chain (Blocks : Block_Array_Type) return Boolean is
   begin
      if Blocks'Length <= 1 then
         return True;
      end if;
      for I in Blocks'First .. Blocks'Last - 1 loop
         if Blocks (I + 1).Prev_Hash /= Blocks (I).State_Hash then
            return False;
         end if;
      end loop;
      return True;
   end Valid_Chain;

end PvsNP_SPARK;
