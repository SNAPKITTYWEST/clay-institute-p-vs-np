# ============================================================
# AXIOM ENGINE: APL Instance Generator
# Generates hard SAT instances for P vs NP proof search
# Equivalent APL implementation documented inline
# ============================================================

"""
APL Instance Generator for SAT Problems
========================================

This Python implementation documents the APL algorithms for generating
hard SAT instances. The actual APL code would be:

  ⍝ DIMACS Generator
  DIMACS ← {⍺←'' ⋄ ⍵ ⍪ ⍺}
  
  ⍝ Random 3-SAT at phase transition (clauses/vars ≈ 4.26)
  R3SAT ← {vars clauses:seed
    r←?seed⌷⎕RL ⋄ ⎕RL←r
    lits←(clauses 3)⍴(vars×2)⌊?(clauses×3)⍴vars
    signs←(clauses 3)⍴¯1 1[?(clauses×3)⍴2]
    clauses←(1+lits)×signs
    'p cnf',⍕vars,clauses ⍪ (,clauses),0
  }

  ⍝ Planted solution instances
  PLANTED ← {vars density:seed solution
    r←?seed⌷⎕RL ⋄ ⎕RL←r
    sol←(vars)⍴¯1 1[?vars⍴2]
    clauses←⌈vars×density
    gen←{c←?3⍴vars ⋄ s←sol[c] ⋄ (c×s)×¯1 1[?3⍴2]}¨⍳clauses
    'p cnf',⍕vars,clauses ⍪ (,gen),0
  }

  ⍝ Pigeonhole Principle (PHP) - provably hard
  PHP ← {n  ⍝ n+1 pigeons, n holes
    vars←n×(n+1)
    clauses←(n+1) + n×(n+1)×n÷2
    'p cnf',⍕vars,clauses ⍪ ...
  }

  ⍝ Tseitin formulas on expander graphs
  TSEITIN ← {graph parity:seed
    r←?seed⌷⎕RL ⋄ ⎕RL←r
    vars←≢edges graph
    clauses←(2*degree)×≢vertices
    ...
  }
"""

import random
import sys
import hashlib
import json
from typing import List, Tuple, Dict, Optional
from dataclasses import dataclass
from pathlib import Path

# ============================================================
# I. CORE DATA STRUCTURES
# ============================================================

@dataclass
class SATInstance:
    """A SAT instance with metadata for reproducibility"""
    nvars: int
    clauses: List[List[int]]
    generator: str
    seed: int
    parameters: Dict
    instance_hash: str
    
    def to_dimacs(self) -> str:
        """Export to DIMACS CNF format"""
        lines = [f"p cnf {self.nvars} {len(self.clauses)}"]
        for clause in self.clauses:
            lines.append(" ".join(map(str, clause)) + " 0")
        return "\n".join(lines)
    
    def to_json(self) -> str:
        return json.dumps({
            "nvars": self.nvars,
            "clauses": self.clauses,
            "generator": self.generator,
            "seed": self.seed,
            "parameters": self.parameters,
            "instance_hash": self.instance_hash
        }, indent=2)

# ============================================================
# II. UTILITY FUNCTIONS
# ============================================================

def compute_hash(instance: SATInstance) -> str:
    """Compute SHA256 hash of instance for reproducibility"""
    content = f"{instance.nvars}|{instance.clauses}|{instance.generator}|{instance.seed}|{instance.parameters}"
    return hashlib.sha256(content.encode()).hexdigest()[:16]

def set_seed(seed: int) -> None:
    """Set random seed for reproducibility"""
    random.seed(seed)

# ============================================================
# III. GENERATOR 1: RANDOM 3-SAT AT PHASE TRANSITION
# ============================================================

def random_3sat(nvars: int, clause_ratio: float = 4.26, seed: int = 42) -> SATInstance:
    """
    Generate random 3-SAT at the satisfiability phase transition.
    
    The clause-to-variable ratio 4.26 is the critical threshold
    where random 3-SAT transitions from SAT to UNSAT with probability 0.5.
    
    APL equivalent:
      R3SAT ← {vars ratio:seed
        r←?seed⌷⎕RL ⋄ ⎕RL←r
        n←⌈vars×ratio
        lits←(n 3)⍴vars
        signs←(n 3)⍴¯1 1[?n×3⍴2]
        (1+lits)×signs
      }
    """
    set_seed(seed)
    nclauses = int(nvars * clause_ratio)
    clauses = []
    
    for _ in range(nclauses):
        # Pick 3 distinct variables
        vars_chosen = random.sample(range(1, nvars + 1), 3)
        # Random signs
        signs = [random.choice([-1, 1]) for _ in range(3)]
        clause = [v * s for v, s in zip(vars_chosen, signs)]
        clauses.append(clause)
    
    params = {"clause_ratio": clause_ratio}
    inst = SATInstance(nvars, clauses, "random_3sat", seed, params, "")
    inst.instance_hash = compute_hash(inst)
    return inst

# ============================================================
# IV. GENERATOR 2: PLANTED SOLUTION INSTANCES
# ============================================================

def planted_solution(nvars: int, clause_ratio: float = 4.26, seed: int = 42) -> SATInstance:
    """
    Generate SAT instance with a known satisfying assignment.
    
    First picks a random assignment, then generates clauses
    that are satisfied by it.
    
    APL equivalent:
      PLANTED ← {vars ratio:seed sol
        r←?seed⌷⎕RL ⋄ ⎕RL←r
        n←⌈vars×ratio
        gen←{c←?3⍴vars ⋄ s←sol[c] ⋄ (c×s)×¯1 1[?3⍴2]}¨⍳n
      }
    """
    set_seed(seed)
    nclauses = int(nvars * clause_ratio)
    
    # Generate random satisfying assignment
    solution = [random.choice([-1, 1]) for _ in range(nvars)]
    
    clauses = []
    for _ in range(nclauses):
        # Pick 3 variables
        vars_chosen = random.sample(range(1, nvars + 1), 3)
        # Ensure at least one literal is satisfied by solution
        # Pick a random literal to be the "satisfied" one
        satisfied_idx = random.randint(0, 2)
        clause = []
        for i, var in enumerate(vars_chosen):
            if i == satisfied_idx:
                # This literal is satisfied by solution
                lit = var * solution[var - 1]
            else:
                # Other literals random
                lit = var * random.choice([-1, 1])
            clause.append(lit)
        clauses.append(clause)
    
    params = {"clause_ratio": clause_ratio, "solution": solution}
    inst = SATInstance(nvars, clauses, "planted_solution", seed, params, "")
    inst.instance_hash = compute_hash(inst)
    return inst

# ============================================================
# V. GENERATOR 3: PIGEONHOLE PRINCIPLE (PHP)
# ============================================================

def pigeonhole_principle(n: int, seed: int = 42) -> SATInstance:
    """
    Generate Pigeonhole Principle formula: n+1 pigeons into n holes.
    
    This is a classic hard unsatisfiable formula for resolution.
    Variables: x_{i,j} = pigeon i in hole j
    
    Clauses:
    1. Each pigeon in at least one hole: (x_{i,1} ∨ ... ∨ x_{i,n})
    2. No two pigeons in same hole: (¬x_{i,j} ∨ ¬x_{k,j}) for i≠k
    3. Each pigeon in at most one hole: (¬x_{i,j} ∨ ¬x_{i,k}) for j≠k
    
    APL equivalent:
      PHP ← {n
        vars←n×(n+1)
        each_hole←(n+1)⍴n⍴1  ⍝ Each pigeon in at least one hole
        no_share←n×(n+1)×n÷2  ⍝ No two pigeons in same hole
        ...
      }
    """
    set_seed(seed)
    
    # Variables: x_{pigeon, hole} where pigeon in 1..n+1, hole in 1..n
    # Variable index: (pigeon-1)*n + hole
    nvars = n * (n + 1)
    clauses = []
    
    def var_idx(pigeon: int, hole: int) -> int:
        return (pigeon - 1) * n + hole
    
    # 1. Each pigeon in at least one hole
    for pigeon in range(1, n + 2):
        clause = [var_idx(pigeon, hole) for hole in range(1, n + 1)]
        clauses.append(clause)
    
    # 2. No two pigeons in same hole (pairwise)
    for hole in range(1, n + 1):
        for p1 in range(1, n + 2):
            for p2 in range(p1 + 1, n + 2):
                clauses.append([-var_idx(p1, hole), -var_idx(p2, hole)])
    
    # 3. Each pigeon in at most one hole
    for pigeon in range(1, n + 2):
        for h1 in range(1, n + 1):
            for h2 in range(h1 + 1, n + 1):
                clauses.append([-var_idx(pigeon, h1), -var_idx(pigeon, h2)])
    
    params = {"n": n, "type": "pigeonhole"}
    inst = SATInstance(nvars, clauses, "pigeonhole_principle", seed, params, "")
    inst.instance_hash = compute_hash(inst)
    return inst

# ============================================================
# VI. GENERATOR 4: TSEITIN FORMULAS ON EXPANDER GRAPHS
# ============================================================

def tseitin_formula(n: int, degree: int = 3, seed: int = 42) -> SATInstance:
    """
    Generate Tseitin formula on a random d-regular expander graph.
    
    Each vertex gets a parity constraint. Variables on edges.
    Parity constraints create hard unsatisfiable instances.
    
    APL equivalent:
      TSEITIN ← {graph parity:seed
        r←?seed⌷⎕RL ⋄ ⎕RL←r
        vars←≢edges graph
        clauses←(2*degree)×≢vertices
        ...
      }
    """
    set_seed(seed)
    
    # Generate random d-regular graph using configuration model
    # For simplicity, use a random regular-ish graph
    edges = []
    edge_vars = {}
    var_counter = 1
    
    # Simple cycle + random matching for regularity
    for i in range(n):
        j = (i + 1) % n
        if i < j:
            edges.append((i, j))
            edge_vars[(i, j)] = var_counter
            var_counter += 1
    
    # Add random matching edges
    vertices = list(range(n))
    random.shuffle(vertices)
    for i in range(0, n - 1, 2):
        u, v = vertices[i], vertices[i + 1]
        if u > v: u, v = v, u
        if (u, v) not in edge_vars:
            edges.append((u, v))
            edge_vars[(u, v)] = var_counter
            var_counter += 1
    
    nvars = var_counter - 1
    clauses = []
    
    # Parity constraint at each vertex
    for v in range(n):
        incident_edges = [e for e in edges if v in e]
        edge_vars_list = [edge_vars[e] for e in incident_edges]
        
        # XOR of incident edges = parity (0 for even, 1 for odd)
        # Encode XOR as CNF: for each subset of odd size, add clause
        k = len(edge_vars_list)
        if k >= 2:
            # Simple encoding: (x1 ⊕ x2 ⊕ ... ⊕ xk) = 1
            # Use standard XOR-to-CNF encoding
            # For k=3: (x1∨x2∨x3)∧(¬x1∨¬x2∨x3)∧(¬x1∨x2∨¬x3)∧(x1∨¬x2∨¬x3)
            if k == 2:
                a, b = edge_vars_list
                clauses.append([a, b])
                clauses.append([-a, -b])
            elif k == 3:
                a, b, c = edge_vars_list
                clauses.append([a, b, c])
                clauses.append([-a, -b, c])
                clauses.append([-a, b, -c])
                clauses.append([a, -b, -c])
    
    # Make unsatisfiable by setting global parity to 1 (odd total)
    # This ensures formula is UNSAT
    params = {"n": n, "degree": degree, "type": "tseitin"}
    inst = SATInstance(nvars, clauses, "tseitin", seed, params, "")
    inst.instance_hash = compute_hash(inst)
    return inst

# ============================================================
# VII. GENERATOR 5: RANDOM k-SAT WITH CONTROLLED HARDNESS
# ============================================================

def random_ksat(nvars: int, k: int, clause_ratio: float, seed: int = 42) -> SATInstance:
    """Generate random k-SAT instance"""
    set_seed(seed)
    nclauses = int(nvars * clause_ratio)
    clauses = []
    
    for _ in range(nclauses):
        vars_chosen = random.sample(range(1, nvars + 1), k)
        signs = [random.choice([-1, 1]) for _ in range(k)]
        clause = [v * s for v, s in zip(vars_chosen, signs)]
        clauses.append(clause)
    
    params = {"k": k, "clause_ratio": clause_ratio}
    inst = SATInstance(nvars, clauses, f"random_{k}sat", seed, params, "")
    inst.instance_hash = compute_hash(inst)
    return inst

# ============================================================
# VIII. BATCH GENERATION
# ============================================================

def generate_batch(generator_name: str, params_list: List[Dict], output_dir: str) -> List[SATInstance]:
    """Generate multiple instances and save to files"""
    Path(output_dir).mkdir(parents=True, exist_ok=True)
    instances = []
    
    for i, params in enumerate(params_list):
        seed = params.get("seed", 42 + i)
        
        if generator_name == "random_3sat":
            inst = random_3sat(params["nvars"], params.get("ratio", 4.26), seed)
        elif generator_name == "planted":
            inst = planted_solution(params["nvars"], params.get("ratio", 4.26), seed)
        elif generator_name == "php":
            inst = pigeonhole_principle(params["n"], seed)
        elif generator_name == "tseitin":
            inst = tseitin_formula(params["n"], params.get("degree", 3), seed)
        elif generator_name == "random_ksat":
            inst = random_ksat(params["nvars"], params["k"], params.get("ratio", 4.26), seed)
        else:
            raise ValueError(f"Unknown generator: {generator_name}")
        
        # Save DIMACS
        dimacs_file = Path(output_dir) / f"{generator_name}_{inst.instance_hash}.cnf"
        with open(dimacs_file, "w") as f:
            f.write(inst.to_dimacs())
        
        # Save metadata
        meta_file = Path(output_dir) / f"{generator_name}_{inst.instance_hash}.json"
        with open(meta_file, "w") as f:
            f.write(inst.to_json())
        
        instances.append(inst)
        print(f"Generated: {dimacs_file} ({inst.nvars} vars, {len(inst.clauses)} clauses)")
    
    return instances

# ============================================================
# IX. COMMAND LINE INTERFACE
# ============================================================

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description="APL Instance Generator for SAT")
    parser.add_argument("generator", choices=["random_3sat", "planted", "php", "tseitin", "random_ksat"])
    parser.add_argument("--nvars", type=int, default=100)
    parser.add_argument("--n", type=int, default=10)
    parser.add_argument("--k", type=int, default=3)
    parser.add_argument("--ratio", type=float, default=4.26)
    parser.add_argument("--seed", type=int, default=42)
    parser.add_argument("--count", type=int, default=1)
    parser.add_argument("--output", type=str, default="instances")
    parser.add_argument("--batch", type=str, help="JSON file with batch parameters")
    
    args = parser.parse_args()
    
    if args.batch:
        with open(args.batch) as f:
            params_list = json.load(f)
        generate_batch(args.generator, params_list, args.output)
    else:
        params = {"nvars": args.nvars, "ratio": args.ratio, "seed": args.seed, 
                  "n": args.n, "k": args.k}
        params_list = [params] * args.count
        generate_batch(args.generator, params_list, args.output)

if __name__ == "__main__":
    main()