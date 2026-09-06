/-
Copyright 2026 Ahmad Ali Parr + Jessica Westerhoff
Bel Esprit d'Accord Trust — 50/50 equal sovereigns
SOVEREIGN SOURCE LICENSE v1.0

Shared Foundation Layer 1: Alphabet
  Σ finite nonempty, Σ* strings, binary Σ={0,1} specialization
Box: Σ → Σ* → L → M → Run → T → P/NP → ≤p → SAT → 3SAT
-/

-- Σ : finite nonempty alphabet (finiteness via explicit enumeration, no Mathlib)
structure Alphabet where
  Carrier : Type
  enumerate : List Carrier
  isNonempty : enumerate ≠ []
  decEq : DecidableEq Carrier
  covers : ∀ x : Carrier, x ∈ enumerate

-- Σ* : finite strings over Σ
abbrev Str (Sigma : Type) := List Sigma

-- Binary specialization: Σ = {0,1}
inductive Bin : Type where
  | b0 : Bin
  | b1 : Bin
  deriving DecidableEq, Repr, Inhabited, BEq

def BinAlphabet : Alphabet where
  Carrier := Bin
  enumerate := [Bin.b0, Bin.b1]
  isNonempty := by simp
  decEq := inferInstance
  covers := by intro x; cases x <;> simp

abbrev BinStr := Str Bin -- x ∈ {0,1}*

def binaryIsCanonical : BinStr = Str Bin := rfl
