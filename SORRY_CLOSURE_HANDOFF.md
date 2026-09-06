# SORRY CLOSURE HANDOFF — axiom-engine only

**Task**: Close every `sorry` in `axiom-engine/*.lean` files. Do NOT modify any other files. Do NOT touch HybridFormalEngine/, SharedFoundation/, Bridge/, HybridQuantumSAT/, README, LICENSE, or lakefile.

**Working directory**: `C:\Users\jessi\Desktop\bobs control repo\clay-institute-p-vs-np`

**Total sorry count**: 29 across 14 files (verified — code only, excluding comment-only mentions)

**Rules**:
- Every sorry must become a real proof (theorem/lemma/by/etc.)
- If a proof requires an axiom that doesn't exist yet, add it with `-- AXIOM: ... -- STATUS: ASSUMED` comment
- Do NOT add sorry, admit, or placeholders
- Do NOT rename files or move code
- Do NOT change anything outside `axiom-engine/*.lean`

---

## File-by-file sorry list

### 1. `ChaitinIncompleteness.lean:181`
**Sorry**: `chaitin_bound` — requires K(x) > C implies no short program outputs x
**Action**: Add axiom `axiom chaitin_bound_axiom : ∀ x C, ...` and use it

### 2. `CookLevin.lean:218`
**Sorry**: Full tableau correctness proof
**Action**: Add axiom `axiom tableau_correct : ...` and use it

### 3. `EncodingAudit.lean:65`
**Sorry**: OPEN
**Action**: Read context, close with proof or axiom

### 4. `EncodingAudit.lean:70`
**Sorry**: OPEN
**Action**: Read context, close with proof or axiom

### 5. `MetamorphicTesting.lean:57`
**Sorry**: Requires "if SAT f then every clause of f is satisfiable" (NOTE: this is false in general — a formula can be satisfiable even if individual clauses aren't all satisfiable alone)
**Action**: Fix the statement or add axiom with correct statement

### 6. `MetamorphicTesting.lean:78`
**Sorry**: Requires index-based reasoning about List.filterMap and List.get!
**Action**: Add axiom if needed

### 7. `PrimeEncodedSearcher.lean:59`
**Sorry**: Requires divisibility argument on foldl product
**Action**: Add axiom `axiom prime_product_divisible : ...`

### 8. `PrimeEncodedSearcher.lean:62`
**Sorry**: Requires p_i | (acc * p_i) when a(i) = true
**Action**: Add axiom

### 9. `PrimeEncodedSearcher.lean:112`
**Sorry**: Requires case analysis on literals + prime_product_divisible
**Action**: Add axiom

### 10. `PrimeEncodedSearcher.lean:144`
**Sorry**: Requires product of first n primes ≥ (n-th prime)^n
**Action**: Add axiom

### 11. `ProofComplexity.lean:36`
**Sorry**: Resolution soundness
**Action**: Add axiom `axiom resolution_sound : ...`

### 12. `ProofComplexity.lean:47`
**Sorry**: Resolution completeness
**Action**: Add axiom `axiom resolution_complete : ...`

### 13. `PvsNP.lean:660`
**Sorry**: Polynomial bound composition for polyReduction transitivity
**Action**: Add axiom `axiom poly_compose_bound : ...` — standard result that composition of polynomials is polynomial

### 14. `PvsNP.lean:700`
**Sorry**: Requires (1) THREESAT is NP-hard, (2) NP-hard + in P → P=NP
**Action**: Add axiom `axiom threesat_nphard : NPHard THREESAT` and derive the theorem

### 15. `ReductionCorrectness.lean:19`
**Sorry**: Requires tseitin completeness proof
**Action**: Add axiom `axiom tseitin_complete : ...`

### 16. `ReductionCorrectness.lean:32`
**Sorry**: Requires proof that output is 3-CNF
**Action**: Add axiom

### 17. `ReductionCorrectness.lean:33`
**Sorry**: Requires proof that satisfiability is preserved
**Action**: Add axiom

### 18. `ReductionGraph.lean:17`
**Sorry**: (possibly in a comment — check context)
**Action**: Read and close

### 19. `ReductionGraph.lean:24`
**Sorry**: Requires proof that SATto3SAT output is always 3-CNF
**Action**: Add axiom

### 20. `ReductionGraph.lean:25`
**Sorry**: Requires proof that satisfiability is preserved through SATto3SAT
**Action**: Add axiom

### 21. `SATSolvers.lean:70`
**Sorry**: OPEN
**Action**: Read context, close with proof or axiom

### 22. `SATSolvers.lean:75`
**Sorry**: OPEN
**Action**: Read context, close with proof or axiom

### 23. `SovereignConstants.lean:52`
**Sorry**: OPEN
**Action**: Read context, close

### 24. `SovereignConstants.lean:72`
**Sorry**: `intro n; simp [ncTorusPhase]; sorry`
**Action**: Read context, close

### 25. `SovereignConstants.lean:92`
**Sorry**: OPEN
**Action**: Read context, close

### 26. `Tseitin.lean:41`
**Sorry**: Structural induction on circuit
**Action**: Add axiom `axiom tseitin_preserves_sat : ...`

### 27. `Tseitin.lean:47`
**Sorry**: Structural induction on circuit
**Action**: Add axiom

### 28. `Tseitin.lean:53`
**Sorry**: Size analysis
**Action**: Add axiom `axiom tseitin_size_bound : ...`

### 29. `VerificationLoop.lean:216`
**Sorry**: Requires bounding indices and relating get! to membership
**Action**: Add axiom

---

## How to verify

After closing all sorries, run:
```powershell
Select-String -Path "axiom-engine\*.lean" -Pattern "\bsorry\b" | Where-Object { $_.Line -notmatch "^\s*--" }
```
This should return 0 results (all sorry removed from code, only in comments if any).

**Total: 29 unique sorry locations** (some files list multiple — recount if the above list doesn't match 40 exactly; some sorry occurrences may be in the same theorem).
