% ============================================================
% AXIOM ENGINE: Cross-Language Conflict Registry
% Records disagreements between Rust, Ada, Lean, Liquid Haskell
%
% STATUS: All conflicts documented
% ============================================================

:- module(conflicts, [
    conflict/3,
    conflict_status/2,
    conflict_resolution/2
]).

% ============================================================
% I. DETECTED CONFLICTS
% ============================================================

% CONFLICT-000001: evalClause empty clause behavior
% RUST: eval_clause([], _) = B0 (via fold)
% ADA:  Eval_Clause requires Clause'Length > 0 (precondition)
% LEAN: evalClause [] _ = B0 (pattern match)
% LH:   evalClause [] _ = B0 (pattern match)
%
% Ada's precondition means empty clause is undefined behavior.
% Rust/Lean/LH explicitly return B0.
% Resolution: Ada contract is STRONGER (precondition needed).
conflict(conflict_000001,
    'evalClause empty clause behavior',
    'Ada requires ClauseLength > 0, Rust/Lean/LH return B0').
conflict_status(conflict_000001, documented).
conflict_resolution(conflict_000001, 'Ada precondition is stronger; Lean/Rust/LH handle gracefully').

% CONFLICT-000002: evalFormula empty formula behavior
% RUST: eval_formula([], _) = B1 (via fold)
% ADA:  Eval_Formula requires Formula'Length > 0 (precondition)
% LEAN: evalFormula [] _ = B1 (pattern match)
% LH:   evalFormula [] _ = B1 (pattern match)
%
% Same pattern as CONFLICT-000001.
conflict(conflict_000002,
    'evalFormula empty formula behavior',
    'Ada requires FormulaLength > 0, Rust/Lean/LH return B1').
conflict_status(conflict_000002, documented).
conflict_resolution(conflict_000002, 'Ada precondition is stronger; Lean/Rust/LH handle gracefully').

% CONFLICT-000003: Variable type representation
% RUST: Variable = usize (unsigned, potentially large)
% ADA:  Variable_Type is Natural (non-negative integer)
% LEAN: Variable := Nat (natural number)
% LH:   Variable = Int (signed integer)
%
% LH uses signed integers while others use unsigned/natural.
% This means LH could have negative variable indices.
conflict(conflict_000003,
    'Variable type signedness',
    'LH uses Int (signed), others use Nat/Natural/usize (unsigned)').
conflict_status(conflict_000003, documented).
conflict_resolution(conflict_000003, 'LH refinements ensure non-negativity at runtime').

% CONFLICT-000004: WORMBlock timestamp type
% RUST: timestamp: i64 (signed 64-bit)
% ADA:  Timestamp: Integer (unbounded signed)
% LEAN: timestamp: Int (unbounded signed)
% LH:   timestamp: Integer (unbounded signed)
%
% Rust truncates to 64 bits; others are unbounded.
conflict(conflict_000004,
    'WORMBlock timestamp boundedness',
    'Rust i64 bounded, Ada/Lean/LH unbounded Integer').
conflict_status(conflict_000004, documented).
conflict_resolution(conflict_000004, 'Rust assumes practical timestamp range; overflow is system-specific').

% CONFLICT-000005: Spectral gap integer vs real
% RUST: spectral_gap uses u64 (integer arithmetic)
% ADA:  Spectral_Gap uses Natural (integer arithmetic)
% LEAN: spectralGap uses Nat (integer arithmetic)
% LH:   spectralGap uses Int (integer arithmetic)
% LEAN (SpectralGap.lean): spectralGapFunction uses Real (real arithmetic)
%
% Core definitions use integer division; SpectralGap.lean uses real division.
% Integer division truncates; real division is exact.
conflict(conflict_000005,
    'Spectral gap integer vs real arithmetic',
    'Core uses integer division, SpectralGap.lean uses Real division').
conflict_status(conflict_000005, documented).
conflict_resolution(conflict_000005, 'Integer version is implementation; Real version is formal proof').

% CONFLICT-000006: Tseitin termination
% RUST: Tseitin is non-terminating (recursive, no termination proof)
% ADA:  Not implemented (no Tseitin in SPARK)
% LEAN: tseitin is total (termination_by g => g.size)
% LH:   tseitin is non-terminating (recursive, no termination proof)
%
% Lean's tseitin is total; Rust/LH versions are partial.
conflict(conflict_000006,
    'Tseitin termination',
    'Lean tseitin is total, Rust/LH are partial functions').
conflict_status(conflict_000006, documented).
conflict_resolution(conflict_000006, 'Lean version is canonical; Rust/LH versions are implementation-only').

% ============================================================
% II. NO-CONFLICT ZONES
% ============================================================

% The following invariants have NO cross-language conflicts:
%
% - Bit algebra (neg, and, or): All implementations agree
% - evalLiteral: All implementations agree
% - is3Clause/is3CNF: All implementations agree
% - valid_chain: All implementations agree
% - wick_rotate: All implementations agree
% - euclidean_norm: All implementations agree
% - theta constant: All implementations agree
% - P vs NP status: All implementations agree (UNRESOLVED)
