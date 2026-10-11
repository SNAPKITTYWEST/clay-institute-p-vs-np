∇ result ← GenerateHardSATVectorized num_vars num_clauses;clause_len;vars;signs;clauses;lits
    clause_len ← 3
    
    ⍝ 1. Generate all base variables at once as a matrix (num_clauses × clause_len)
    vars ← ? (num_clauses clause_len) ⍴ num_vars
    
    ⍝ 2. Generate matrix of random signs (1 or ¯1)
    signs ← ¯1 * ? (num_clauses clause_len) ⍴ 2
    
    ⍝ 3. Multiply to apply polarity
    clauses ← vars × signs
    
    ⍝ 4. Split the matrix into a nested array of vectors (matching your original format)
    lits ← ↓ clauses
    
    result ← (num_vars num_clauses clause_len lits)
∇
