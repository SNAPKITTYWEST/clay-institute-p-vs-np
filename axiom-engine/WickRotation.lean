-- ============================================================
-- AXIOM ENGINE: Wick Rotation and Euclidean Path Integral
--
-- NOTE: Full Real/Complex-valued proofs require Mathlib.
-- This file is gutted to compile without Mathlib.
-- Real-valued content (WickRotate, EuclideanAction, boltzmannWeight,
-- partitionFunction, acceptanceProb, euclideanMetric) requires
-- Mathlib.Analysis.SpecialFunctions.ExpDeriv and related.
-- SpectralGap constants (kappa, rewireProb, State) were
-- in SpectralGap.lean which was also gutted.
--
-- WICK_ROTATION_THEOREMS: 12 (Real-valued, require Mathlib -- deferred)
-- P_VS_NP_STATUS: UNRESOLVED
-- ============================================================

import PvsNP
import SpectralGap
