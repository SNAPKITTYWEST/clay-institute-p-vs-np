% ============================================================
% AXIOM ENGINE: Hardening Obligations Registry
% Tracks open proof obligations and hardening requirements
%
% STATUS: All obligations documented
% ============================================================

:- module(hardening, [
    hardening/3,
    hardening_status/2,
    hardening_priority/2
]).

% ============================================================
% I. OPEN PROOF OBLIGATIONS
% ============================================================

% HARDEN-000001: reduction_transitive polynomial bound
% BLOCKED on: AX-000002 (polynomial composition axiom)
% SEVERITY: MEDIUM (the composition part is sorry; correctness is proven)
hardening(harden_000001,
    'reduction_transitive polynomial bound composition',
    'Polynomial bound of composed reductions not proven').
hardening_status(harden_000001, open).
hardening_priority(harden_000001, medium).

% HARDEN-000002: P_neq_NP_implies_3SAT_not_in_P
% BLOCKED on: (1) THREESAT is NP-hard, (2) NP-hard + in P → P = NP
% SEVERITY: LOW (requires NP-hardness proof, which is standard but not formalized)
hardening(harden_000002,
    'P_neq_NP_implies_3SAT_not_in_P',
    'Requires THREESAT NP-hardness and NP-hard + in P → P = NP').
hardening_status(harden_000002, open).
hardening_priority(harden_000002, low).

% HARDEN-000003: Tseitin soundness
% BLOCKED on: monotonicity lemma for state threading
% SEVERITY: HIGH (core to circuit-SAT → 3-SAT reduction)
hardening(harden_000003,
    'Tseitin soundness',
    'Monotonicity lemma for tseitin state threading blocked').
hardening_status(harden_000003, open).
hardening_priority(harden_000003, high).

% HARDEN-000004: Tseitin completeness
% BLOCKED on: same as soundness
% SEVERITY: HIGH
hardening(harden_000004,
    'Tseitin completeness',
    'Monotonicity lemma for tseitin state threading blocked').
hardening_status(harden_000004, open).
hardening_priority(harden_000004, high).

% HARDEN-000005: Tseitin size bound
% BLOCKED on: same as soundness
% SEVERITY: MEDIUM
hardening(harden_000005,
    'Tseitin size bound',
    'Monotonicity lemma for tseitin state threading blocked').
hardening_status(harden_000005, open).
hardening_priority(harden_000005, medium).

% HARDEN-000006: Cook-Levin tableau construction
% BLOCKED on: full tableau encoding details
% SEVERITY: LOW (conceptual proof exists; detailed encoding is tedious)
hardening(harden_000006,
    'Cook-Levin tableau construction',
    'Full tableau encoding with all transition constraints not formalized').
hardening_status(harden_000006, open).
hardening_priority(harden_000006, low).

% HARDEN-000007: Float/real arithmetic theorems
% BLOCKED on: No Mathlib dependency
% SEVERITY: LOW (sovereign constants are trivially true)
hardening(harden_000007,
    'Float/real arithmetic theorems',
    'Real arithmetic beyond decidable equality requires Mathlib').
hardening_status(harden_000007, open).
hardening_priority(harden_000007, low).

% HARDEN-000008: DPLL soundness/completeness
% BLOCKED on: termination and correctness of partial functions
% SEVERITY: LOW (SAT solvers are implementation, not core proof)
hardening(harden_000008,
    'DPLL soundness/completeness',
    'Termination and correctness of DPLL not proven').
hardening_status(harden_000008, open).
hardening_priority(harden_000008, low).

% HARDEN-000009: Resolution soundness/completeness
% BLOCKED on: termination and correctness of resolution
% SEVERITY: LOW (proof complexity is orthogonal to P vs NP)
hardening(harden_000009,
    'Resolution soundness/completeness',
    'Termination and correctness of resolution not proven').
hardening_status(harden_000009, open).
hardening_priority(harden_000009, low).

% HARDEN-000010: Metamorphic testing permutation
% BLOCKED on: index coverage reasoning for permutation
% SEVERITY: LOW (metamorphic testing is validation, not core proof)
hardening(harden_000010,
    'Metamorphic testing permutation',
    'Index coverage for clause permutation not proven').
hardening_status(harden_000010, open).
hardening_priority(harden_000010, low).

% HARDEN-000011: Prime product divisibility
% BLOCKED on: FTA divisibility argument
% SEVERITY: LOW (prime-encoded search is hardware-specific)
hardening(harden_000011,
    'Prime product divisibility',
    'FTA divisibility for prime product injection not proven').
hardening_status(harden_000011, open).
hardening_priority(harden_000011, low).

% HARDEN-000012: Prime product injectivity
% BLOCKED on: FTA injectivity argument
% SEVERITY: LOW
hardening(harden_000012,
    'Prime product injectivity',
    'FTA injectivity for prime product mapping not proven').
hardening_status(harden_000012, open).
hardening_priority(harden_000012, low).

% ============================================================
% II. HARDENING SUMMARY
% ============================================================

% TOTAL_OBLIGATIONS: 12
% HIGH_PRIORITY: 3 (Tseitin soundness/completeness/size)
% MEDIUM_PRIORITY: 2 (reduction_transitive, Tseitin size)
% LOW_PRIORITY: 7 (P_neq_NP, Cook-Levin, Float, DPLL, Resolution, Metamorphic, Prime)
% BLOCKED_EXTERNAL: 0 (no external assumptions blocking)
% CRYSTALLIZATION_STATUS: CRYSTALLIZED_WITH_DECLARED_OPEN_OBLIGATIONS
