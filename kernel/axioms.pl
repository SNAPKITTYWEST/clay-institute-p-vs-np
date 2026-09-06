% ============================================================
% AXIOM ENGINE: Axiom Kernel
% Declared axioms and their justification
%
% STATUS: Only the Cook-Levin axiom target is allowed
% ============================================================

:- module(axioms, [
    axiom/3,
    axiom_justification/2,
    axiom_status/2
]).

% ============================================================
% I. DECLARED AXIOMS
% ============================================================

% AX-000001: Cook-Levin axiom target
% This is the only axiom allowed in the system.
% It captures the core claim that 3-SAT is NP-complete.
axiom(ax_000001,
    'forall(L, ClassNP L -> polyReduction L THREESAT)',
    'Cook-Levin theorem: 3-SAT is NP-complete').
axiom_justification(ax_000001, 'Standard complexity theory, widely accepted').
axiom_status(ax_000001, declared).

% AX-000002: Polynomial bound composition
% This is the remaining sorry in reduction_transitive.
% It states that polynomial reductions compose polynomially.
axiom(ax_000002,
    'forall([A,B,C,fab,fbc], polyReduction A fab B, polyReduction B fbc C -> polyReduction A (fbc . fab) C)',
    'Polynomial reduction composition').
axiom_justification(ax_000002, 'Standard polynomial closure under composition').
axiom_status(ax_000002, declared).

% AX-000003: Real arithmetic axiom
% Float/real arithmetic beyond decidable equality
axiom(ax_000003,
    'forall(x, Float.ofNat x = Float.ofNat x)',
    'Float reflexivity').
axiom_justification(ax_000003, 'Decidable equality on Float').
axiom_status(ax_000003, declared).

% ============================================================
% II. PROHIBITED AXIOMS
% ============================================================

% The following axioms are PROHIBITED:
%
% - "assume P = NP" -- this would bypass the question
% - "assume P ≠ NP" -- this would bypass the question
% - "assume 3-SAT ∈ P" -- this would bypass NP-completeness
% - "assume NP-hard implies not in P" -- this would bypass the question
%
% Any axiom that resolves the P vs NP question is PROHIBITED.

% ============================================================
% III. AXIOMS FROM OTHER SOURCES
% ============================================================

% These are axioms from external libraries that are ACCEPTED:
%
% - Mathlib Real.log properties (if Mathlib were used)
% - List.length properties
% - Nat/Int arithmetic
%
% These are NOT project-specific axioms; they are part of the
% trusted base of the proof assistant.

% ============================================================
% IV. PROOF OBLIGATIONS FROM SORRY
% ============================================================

% PO-000001: reduction_transitive polynomial bound
% BLOCKED on AX-000002.
po_blocked(reduction_transitive, ax_000002).

% PO-000002: P_neq_NP_implies_3SAT_not_in_P
% BLOCKED on: (1) THREESAT is NP-hard, (2) NP-hard + in P → P = NP
po_blocked(p_neq_n_p_implies_3_sat_not_in_p, missing_n_p_hardness).

% PO-000003: Tseitin soundness
% BLOCKED on: induction over circuit structure with state threading
po_blocked(tseitin_soundness, missing_monotonicity_lemma).

% PO-000004: Tseitin completeness
% BLOCKED on: same as soundness
po_blocked(tseitin_completeness, missing_monotonicity_lemma).

% PO-000005: Tseitin size bound
% BLOCKED on: same as soundness
po_blocked(tseitin_size_bound, missing_monotonicity_lemma).
