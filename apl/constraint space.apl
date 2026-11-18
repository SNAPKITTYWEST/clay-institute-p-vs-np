∇ result ← GenerateHardSATUnique num_vars num_clauses;clause_len;vars;signs;lits
    clause_len ← 3
    
    ⍝ 1. Deal 3 distinct variables for each clause without replacement
    ⍝ ?¨ applies the Deal operator to each element in the right argument
    vars ← clause_len ?¨ num_clauses ⍴ num_vars
    
    ⍝ 2. Generate flat matrix of random signs and split (↓) into nested array
    signs ← ↓ ¯1 * ? (num_clauses clause_len) ⍴ 2
    
    ⍝ 3. Apply signs by multiplying element-wise across the nested arrays (×¨)
    lits ← vars ×¨ signs
    
    result ← (num_vars num_clauses clause_len lits)
∇
