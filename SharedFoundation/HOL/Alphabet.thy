theory Alphabet
imports Main
begin
(* Shared Foundation Layer 1 — Isabelle/HOL implementation
   Targets Spec.md: Σ finite nonempty, Σ*, binary Σ={0,1} *)

typedecl Sigma
axiomatization where finite_Sigma: "finite (UNIV :: Sigma set)"
 and nonempty_Sigma: "∃x::Sigma. True"

type_synonym 'a Str = "'a list"
type_synonym BinStr = "bool list"  (* x ∈ {0,1}* canonical *)

end
