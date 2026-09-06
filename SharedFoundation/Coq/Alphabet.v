(* Shared Foundation Layer 1 — Coq implementation
   Targets Spec.md: Σ finite nonempty, Σ*, binary Σ={0,1} *)
Require Import List Bool.
Import ListNotations.

Record Alphabet := {
  Carrier : Type;
  isFinite : Finite Carrier;
  isNonempty : Carrier
}.

Definition Bin := bool. (* {0,1} *)
Definition BinStr := list Bin. (* x ∈ {0,1}* *)
