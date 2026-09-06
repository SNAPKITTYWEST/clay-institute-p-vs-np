/-
Copyright 2026 Ahmad Ali Parr + Jessica Westerhoff
Shared Foundation Layer 2: Encoding
  enc: X → Σ* , dec: Σ* ⇀ X , dec(enc(x))=x
-/
import SharedFoundation.Alphabet

-- Abstract encoding for finite object type X into strings over Σ
structure Encoding (X Sigma : Type) where
  enc : X → List Sigma
  dec : List Sigma → Option X
  roundTrip : ∀ x : X, dec (enc x) = some x

def decodesTo {X Sigma : Type} (E : Encoding X Sigma) (s : List Sigma) (x : X) : Prop :=
  E.dec s = some x

inductive EncodableKind where
  | boolFormula | circuit | turingMachine | certificate | decisionInstance | reduction
  deriving DecidableEq, Repr

structure EncodingFamily (Sigma : Type) where
  carrier : EncodableKind → Type
  encoding : (k : EncodableKind) → Encoding (carrier k) Sigma

abbrev BinEncoding (X : Type) := Encoding X Bin

