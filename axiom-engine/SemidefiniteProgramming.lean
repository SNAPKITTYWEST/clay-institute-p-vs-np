-- ============================================================
-- AXIOM ENGINE: Semidefinite Programming
-- Convex optimization and approximation
-- ============================================================

import PvsNP

-- ============================================================
-- I. SDP RELAXATION
-- ============================================================

-- Semidefinite programming: optimize linear objective over
-- positive semidefinite cone
-- Solvable in polynomial time (interior point methods)

-- ============================================================
-- II. MAX-CUT (GOEMANS-WILLIAMSON)
-- ============================================================

-- SDP relaxation for MAX-CUT
-- 0.878-approximation ratio
-- Implying NP-hard to approximate within 0.9424 (Håstad)

-- ============================================================
-- III. CONNECTION TO P VS NP
-- ============================================================

-- SDP provides approximation algorithms
-- Does not imply P = NP

-- ============================================================
-- IV. FINAL STATUS
-- ============================================================

-- SDP: YES
-- MAX_CUT_APPROXIMATION: 0.878
-- GOEMANS_WILLIAMSON: YES
-- P_VS_NP_STATUS: UNRESOLVED
