# Phase 3: Multi-Agent Orchestration

## Agent Roles

### ATLAS
Manages distributed task queues across local nodes and external compute workers. Maintains the Small-World routing matrix.

### TENSOR
Handles algebraic reductions, polynomial ring transformations, and matrix representations of circuit complexity models.

### LEDGE
Enforces WORM sealing, verifies cryptographic hashes, maintains append-only audit logs.

### AXIOM
Executes formal type-checking, automated theorem proving, strict proof obligation decomposition.

## Proof Strategies & Barriers

### Circuit Lower Bounds
Non-monotone circuit families (NC¹ ≠ P). Encountered Razborov-Rudich Natural Proofs Barrier.

### Diagonalization
Oracle Turing machines: P^A = NP^A for some A, P^B ≠ NP^B for B. Standard diagonalization cannot resolve.

### Algebraic
Permanent vs determinant (VNP ≠ VP). Multilinear algebra invariants over characteristic-2 fields.

## Verification Loop

```
While search_active:
  1. TENSOR generates candidate lemma
  2. Decompose into PO1-PO8 obligations
  3. AXIOM formal type check
  If passed: LEDGE.seal_to_worm(lemma_certificate)
  Else: Refine and retry
```
