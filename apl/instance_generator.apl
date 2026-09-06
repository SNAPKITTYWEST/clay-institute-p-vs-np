⍝ ============================================================
⍝ AXIOM ENGINE: APL Instance Generator
⍝ Generates hard SAT instances for P vs NP proof search
⍝ ============================================================

⍝ APL Instance Generator for SAT Problems
⍝ =========================================
⍝
⍝ This APL code generates hard SAT instances for P vs NP research.
⍝ All instances are reproducible via seed.
⍝
⍝ Instance types:
⍝   R3SAT    - Random 3-SAT at phase transition (ratio ≈ 4.26)
⍝   PLANTED  - Planted solution instances
⍝   PHP      - Pigeonhole Principle (provably hard for resolution)
⍝   TSEITIN  - Tseitin formulas on expander graphs
⍝   RANDOM_K - Random k-SAT with controlled hardness

⍝ ============================================================
⍝ I. UTILITY FUNCTIONS
⍝ ============================================================

⍝ Compute SHA256 hash of instance (using external tool)
HASH ← {⍵ ⎕NL ''} ⍝ Placeholder - uses external hash tool

⍝ Set random seed
SEED ← {⎕RL ← ⍵}

⍝ Literal utilities
LITVAR ← {⍺ ⌈/ ⍵} ⍝ Absolute value of literal
LITSIGN ← {1 ¯1 ÷⍨ 1 + 2×⍵<0} ⍝ Sign of literal
LITNEG ← {¯1 × ⍵} ⍝ Negate literal

⍝ Convert literal to index for watch scheme
LITIDX ← {⍵ + 10001} ⍝ Offset by MAX_VARS + 1

⍝ ============================================================
⍝ II. RANDOM 3-SAT AT PHASE TRANSITION
⍝ ============================================================

⍝ The clause-to-variable ratio 4.26 is the critical threshold
⍝ where random 3-SAT transitions from SAT to UNSAT.

R3SAT ← {
    ⍝ Input: nvars ratio seed
    ⍝ Output: DIMACS CNF string
    nvars ← ⍺[1]
    ratio ← ⍺[2]
    seed ← ⍺[3]
    SEED seed
    nclauses ← ⌈nvars × ratio
    lits ← (nclauses 3) ⍴ ?(nclauses×3) ⍴ nvars
    signs ← (nclauses 3) ⍴ ¯1 1 [?(nclauses×3) ⍴ 2]
    clauses ← (1+lits) × signs
    'p cnf', ⍕nvars, nclauses, ⍪ (,clauses), 0
}

⍝ APL equivalent for random 3-SAT:
⍝   nclauses ← ⌈nvars × ratio
⍝   lits ← (nclauses 3) ⍴ ?(nclauses×3) ⍴ nvars
⍝   signs ← (nclauses 3) ⍴ ¯1 1 [?(nclauses×3) ⍴ 2]
⍝   clauses ← (1+lits) × signs

⍝ ============================================================
⍝ III. PLANTED SOLUTION INSTANCES
⍝ ============================================================

⍝ Generate SAT instance with a known satisfying assignment.
⍝ First picks a random assignment, then generates clauses
⍝ that are satisfied by it.

PLANTED ← {
    ⍝ Input: nvars ratio seed
    nvars ← ⍺[1]
    ratio ← ⍺[2]
    seed ← ⍺[3]
    SEED seed
    nclauses ← ⌈nvars × ratio
    
    ⍝ Generate random satisfying assignment
    sol ← (nvars) ⍴ ¯1 1 [?(nvars) ⍴ 2]
    
    ⍝ Generate clauses satisfied by sol
    clauses ← []
    :For i :In ⍳nclauses
        vars ← ?3 ⍴ nvars
        satisfied_idx ← ?3
        clause ← []
        :For j :In ⍳3
            v ← vars[j]
            :If j = satisfied_idx
                lit ← v × sol[v]
            :Else
                lit ← v × ¯1 1 [?(1) ⍴ 2]
            :EndIf
            clause ← clause, lit
        :EndFor
        clauses ← clauses, ⊂clause
    :EndFor
    
    'p cnf', ⍕nvars, nclauses, ⍪ (,clauses), 0
}

⍝ APL equivalent:
⍝   sol ← (nvars) ⍴ ¯1 1 [?(nvars) ⍴ 2]
⍝   gen ← {c ← ?3 ⍴ nvars ⋄ s ← sol[c] ⋄ (c×s) × ¯1 1 [?3 ⍴ 2]}
⍝   clauses ← gen ¨ ⍳nclauses

⍝ ============================================================
⍝ IV. PIGEONHOLE PRINCIPLE (PHP)
⍝ ============================================================

⍝ Generate Pigeonhole Principle formula: n+1 pigeons into n holes.
⍝ Variables: x_{i,j} = pigeon i in hole j
⍝ This is a classic hard unsatisfiable formula for resolution.

PHP ← {
    ⍝ Input: n (number of holes, n+1 pigeons)
    n ← ⍺
    
    ⍝ Variables: x_{pigeon, hole} where pigeon in 1..n+1, hole in 1..n
    ⍝ Variable index: (pigeon-1)*n + hole
    
    nvars ← n × (n+1)
    clauses ← []
    
    ⍝ Each pigeon in at least one hole
    :For pigeon :In ⍳n+1
        clause ← (n) ⍴ 1
        :For hole :In ⍳n
            clause[hole] ← (pigeon-1)×n + hole
        :EndFor
        clauses ← clauses, ⊂clause
    :EndFor
    
    ⍝ No two pigeons in same hole (pairwise)
    :For hole :In ⍳n
        :For p1 :In ⍳n+1
            :For p2 :In ⍳p1+1 .. n+1
                clauses ← clauses, ⊂{-(p1-1)×n+hole, -(p2-1)×n+hole}
            :EndFor
        :EndFor
    :EndFor
    
    ⍝ Each pigeon in at most one hole
    :For pigeon :In ⍳n+1
        :For h1 :In ⍳n
            :For h2 :In ⍳h1+1 .. n
                clauses ← clauses, ⊂{-(pigeon-1)×n+h1, -(pigeon-1)×n+h2}
            :EndFor
        :EndFor
    :EndFor
    
    'p cnf', ⍕nvars, ≢clauses, ⍪ (,clauses), 0
}

⍝ APL equivalent:
⍝   var_idx ← {(pigeon-1)×n + hole}
⍝   each_hole ← (n+1) ⍴ n ⍴ 1
⍝   no_share ← n × (n+1) × n÷2

⍝ ============================================================
⍝ V. TSEITIN FORMULAS ON EXPANDER GRAPHS
⍝ ============================================================

⍝ Generate Tseitin formula on a random d-regular expander graph.
⍝ Each vertex gets a parity constraint. Variables on edges.

TSEITIN ← {
    ⍝ Input: n (number of vertices), degree (regularity), seed
    n ← ⍺[1]
    degree ← ⍺[2]
    seed ← ⍺[3]
    SEED seed
    
    ⍝ Generate random d-regular graph using configuration model
    edges ← []
    edge_vars ← {}
    var_counter ← 1
    
    ⍝ Simple cycle + random matching for regularity
    :For i :In ⍳n
        j ← (i+1) mod n
        :If i < j
            edges ← edges, ⊂(i,j)
            edge_vars[(i,j)] ← var_counter
            var_counter ← var_counter + 1
        :EndIf
    :EndFor
    
    ⍝ Add random matching edges
    vertices ← ⍳n
    vertices ← ?n ⍴ vertices
    :For i :In ⍳0 .. n-1 .. 2
        u ← vertices[i]
        v ← vertices[i+1]
        :If u > v
            temp ← u
            u ← v
            v ← temp
        :EndIf
        :If (u,v) ∉ edge_vars
            edges ← edges, ⊂(u,v)
            edge_vars[(u,v)] ← var_counter
            var_counter ← var_counter + 1
        :EndIf
    :EndFor
    
    nvars ← var_counter - 1
    clauses ← []
    
    ⍝ Parity constraint at each vertex
    :For v :In ⍳n
        incident_edges ← {e :In edges | v ∈ e}
        edge_vars_list ← {edge_vars[e] : e ∈ incident_edges}
        k ← ≢edge_vars_list
        :If k ≥ 2
            ⍝ XOR encoding as CNF
            :If k = 2
                a ← edge_vars_list[1]
                b ← edge_vars_list[2]
                clauses ← clauses, ⊂{a,b}
                clauses ← clauses, ⊂{¯a,¯b}
            :ElseIf k = 3
                a ← edge_vars_list[1]
                b ← edge_vars_list[2]
                c ← edge_vars_list[3]
                clauses ← clauses, ⊂{a,b,c}
                clauses ← clauses, ⊂{¯a,¯b,c}
                clauses ← clauses, ⊂{¯a,b,¯c}
                clauses ← clauses, ⊂{a,¯b,¯c}
            :EndIf
        :EndIf
    :EndFor
    
    'p cnf', ⍕nvars, ≢clauses, ⍪ (,clauses), 0
}

⍝ APL equivalent:
⍝   edges ← cycle + random_matching
⍝   parity ← {xor of incident edges = 1}
⍝   clauses ← parity_encoding each vertex

⍝ ============================================================
⍝ VI. RANDOM k-SAT WITH CONTROLLED HARDNESS
⍝ ============================================================

⍝ Generate random k-SAT instance

RANDOM_K ← {
    ⍝ Input: nvars k clause_ratio seed
    nvars ← ⍺[1]
    k ← ⍺[2]
    ratio ← ⍺[3]
    seed ← ⍺[4]
    SEED seed
    nclauses ← ⌈nvars × ratio
    
    ⍝ Generate random k-SAT clauses
    clauses ← []
    :For i :In ⍳nclauses
        vars ← ?k ⍴ nvars
        signs ← (k) ⍴ ¯1 1 [?(k) ⍴ 2]
        clause ← (vars × signs)
        clauses ← clauses, ⊂clause
    :EndFor
    
    'p cnf', ⍕nvars, nclauses, ⍪ (,clauses), 0
}

⍝ APL equivalent:
⍝   lits ← (nclauses k) ⍴ ?(nclauses×k) ⍴ nvars
⍝   signs ← (nclauses k) ⍴ ¯1 1 [?(nclauses×k) ⍴ 2]
⍝   clauses ← (1+lits) × signs

⍝ ============================================================
⍝ VII. BATCH GENERATION
⍝ ============================================================

⍝ Generate multiple instances and save to files

BATCH ← {
    ⍝ Input: generator_name params_list output_dir
    gen ← ⍺[1]
    params ← ⍺[2]
    out ← ⍺[3]
    
    instances ← []
    :For i :In ⍳≢params
        seed ← params[i,'seed']
        result ← (gen, params[i]) ⍺ seed
        instances ← instances, ⊂result
        ⎕OUT ← out, '/', gen, '_', HASH result, '.dimacs'
        ⎕OUT ← out, '/', gen, '_', HASH result, '.json'
    :EndFor
    
    instances
}

⍝ ============================================================
⍝ VIII. INSTANCE CLASSES
⍝ ============================================================

⍝ Classification of generated instances:
⍝
⍝   RANDOM_3SAT    - Phase transition instances (ratio 4.26)
⍝   PLANTED        - Known satisfying assignment
⍝   PHP            - Pigeonhole Principle (UNSAT)
⍝   TSEITIN        - Parity constraints on expander
⍝   RANDOM_K       - Controlled hardness k-SAT

⍝ Instance class markers:
⍝   CLASS_RANDOM    ← 'R3SAT'
⍝   CLASS_PLANTED   ← 'PLANTED'
⍝  _CLASS_PHP       ← 'PHP'
⍝   CLASS_TSEITIN   ← 'TSEITIN'
⍝   CLASS_RANDOM_K  ← 'RANDOM_K'

⍝ ============================================================
⍝ IX. REPRODUCIBILITY
⍝ ============================================================

⍝ Every instance is reproducible via seed.
⍝ Instance hash = SHA256(nvars | clauses | generator | seed | parameters)
⍝
⍝ APL equivalent:
⍝   hash ← {⍵ ⎕NL ''} ⍝ Uses external hash tool
⍝   instance_hash ← SHA256 (nvars, clauses, generator, seed, parameters)

⍝ ============================================================
⍝ X. COMMAND LINE INTERFACE
⍝ ============================================================

⍝ Usage:
⍝   apl_instance_generator R3SAT 100 4.26 42
⍝   apl_instance_generator PLANTED 100 4.26 42
⍝   apl_instance_generator PHP 10
⍝   apl_instance_generator TSEITIN 50 3 42
⍝   apl_instance_generator RANDOM_K 100 3 4.26 42

⍝ Batch mode:
⍝   apl_instance_generator BATCH params.json output_dir/

⍝ ============================================================
⍝ END OF APL INSTANCE GENERATOR
⍝ ============================================================