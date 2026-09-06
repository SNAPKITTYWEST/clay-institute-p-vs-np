/-
Copyright 2026 Ahmad Ali Parr + Jessica Westerhoff
Shared Foundation Layer 3: Decision Language
  L ⊆ Σ* , x∈L , L(x):Bool / Prop , question Does x∈L?
-/

-- L ⊆ Σ* as predicate on strings
def Language (Sigma : Type) := List Sigma → Prop
def LanguageBool (Sigma : Type) := List Sigma → Bool

-- Membership predicate x ∈ L
def memLanguage {Sigma : Type} (L : Language Sigma) (x : List Sigma) : Prop := L x

-- Equivalently L(x):Bool or L(x):Prop — we provide both views with coherence
structure DecisionProblem (Sigma : Type) where
  langProp : Language Sigma
  langBool : LanguageBool Sigma
  coherent : ∀ x, langProp x ↔ langBool x = true

-- Fundamental question: Does x ∈ L?  (no computational commitment yet)
def decidesQuestion {Sigma : Type} (L : Language Sigma) (x : List Sigma) : Prop :=
  L x ∨ ¬ L x

