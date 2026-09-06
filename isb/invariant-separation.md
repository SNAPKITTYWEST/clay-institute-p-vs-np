# ISB: Invariant Separation Boundary

## Mathematical Construction

Let M be the manifold of all boolean functions {0,1}^n → {0,1}.
Let C be the space of all circuit families.

ISB : M × C → ℝ where ISB(φ, C) = 0

Formal definition:
ISB = {(φ, C) ∈ M × C | comp(φ) = cap(C)}

Invariant Separation occurs when d(ISB(NP), ISB(P)) > ω(n^k) for all k.

## Barrier Avoidance Lemmas

### Lemma 1: Non-Naturalization (Razborov-Rudich)
The ISB is not a Natural Property.

Proof: ISB is defined via non-constructive invariant χ derived from spectral gap of Small-World routing matrix. Since χ is computed via Wick-rotated manifold hitting time (not known to be in P), ISB does not satisfy Constructivity. Does not naturalize.

### Lemma 2: Non-Relativization
The ISB does not relativize.

Proof: ISB construction relies on physical topology of FPGA cluster (non-local Wormhole coupling). Oracle A provides information but not non-local hardware connectivity. Result is architecture-specific. Does not relativize.

### Lemma 3: Non-Algebrization
The ISB is not an algebrization.

Proof: ISB defined over Discrete Hypercube {0,1}^n using XOR-diff ⊕ and discrete LFSR phase-shift. Operations do not map linearly to polynomial ring F_q[x₁,...,x_n] without losing Wormhole connectivity. Does not algebrize.
