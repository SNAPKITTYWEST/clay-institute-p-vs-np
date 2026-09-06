-- Shared Foundation Layer 1 — Agda implementation
-- Targets Spec.md: Σ finite nonempty, Σ*, binary Σ={0,1}
module SharedFoundation.Agda.Alphabet where

open import Data.List
open import Data.Bool

record Alphabet : Set₁ where
  field
    Carrier : Set
    isFinite : IsFinite Carrier  -- via enumeration
    isNonempty : Carrier

Bin : Set
Bin = Bool  -- {0,1} canonical specialization

BinStr : Set
BinStr = List Bin  -- x ∈ {0,1}*
