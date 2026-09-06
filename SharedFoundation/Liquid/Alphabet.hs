{-# LANGUAGE GADTs #-}
{- Shared Foundation Layer 1 — Liquid Haskell implementation
   Targets Spec.md: Σ finite nonempty, Σ*, binary Σ={0,1} -}
module SharedFoundation.Liquid.Alphabet where

{-@ type Bin = {v:Bool | true} @-}  -- {0,1} canonical
{-@ type BinStr = [Bin] @-}          -- x ∈ {0,1}*

-- Alphabet refinement: finite nonempty carrier
{-@ data Alphabet = Alphabet { carrier :: [a], finite :: {v:Bool| len carrier > 0} } @-}
data Alphabet a = Alphabet { carrier :: [a] }
