⍝ P vs NP Attack: APL Problem Generator
⍝ Generates hard SAT instances for testing solvers
⍝ Seals every attempt to WORM ledger

∇ result ← GenerateHardSAT num_vars num_clauses;clause_len;lits;i;j;lit
    ⍝ Generate random 3-SAT instance at phase transition
    ⍝ Phase transition: clauses/vars ≈ 4.267 (hardest instances)
    
    clause_len ← 3
    lits ← ⍬
    
    :For i :In ⍳num_clauses
        clause ← ⍬
        :For j :In ⍳clause_len
            ⍝ Random variable (1 to num_vars)
            lit ← ?num_vars
            ⍝ Random polarity (positive or negative)
            :If 2|?2
                lit ← -lit
            :EndIf
            clause ← clause,lit
        :EndFor
        lits ← lits,⊂clause
    :EndFor
    
    result ← (num_vars num_clauses clause_len lits)
∇

∇ seal ← SealToWORM instance solver_result;hash;timestamp
    ⍝ Seal SAT solving attempt to WORM ledger
    hash ← SHA256 (⍕instance)
    timestamp ← ⍕⎕TS
    seal ← 'env-',hash,'-',timestamp
    ⍝ Append to ledger file
    AppendToLedger seal instance solver_result
∇

∇ AppendToLedger seal instance result
    ⍝ Append entry to WORM ledger
    entry ← seal,'|',(⍕instance),'|',(⍕result)
    'pnp_worm.jsonl' AppendToFile entry
∇

∇ stats ← AnalyzeInstances num_instances;instances;times;sat_count;unsat_count
    ⍝ Generate and analyze multiple SAT instances
    instances ← ⍬
    times ← ⍬
    sat_count ← 0
    unsat_count ← 0
    
    :For i :In ⍳num_instances
        ⍝ Generate hard instance
        inst ← GenerateHardSAT 20 85  ⍝ ratio ≈ 4.25 (phase transition)
        instances ← instances,⊂inst
        
        ⍝ Solve with Fortran solver
        start_time ← ⎕AI[3]
        result ← SolveWithFortran inst
        end_time ← ⎕AI[3]
        
        elapsed ← end_time - start_time
        times ← times,elapsed
        
        :If result.satisfied
            sat_count ← sat_count + 1
        :Else
            unsat_count ← unsat_count + 1
        :EndIf
        
        ⍝ Seal to WORM
        SealToWORM inst result
    :EndFor
    
    stats ← (sat_count unsat_count (⌈/times) (⌊/times) (+/times)÷num_instances)
∇

⍝ Example usage:
⍝ stats ← AnalyzeInstances 1000
⍝ 'Satisfied:',⍕stats[1]
⍝ 'Unsatisfied:',⍕stats[2]
⍝ 'Max time:',⍕stats[3],'ms'
⍝ 'Min time:',⍕stats[4],'ms'
⍝ 'Avg time:',⍕stats[5],'ms'
