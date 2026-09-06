// ============================================================
// AXIOM ENGINE: Rust Core
// P vs NP Multi-Formalization Implementation
// ============================================================

use std::collections::HashMap;

// ============================================================
// I. CORE TYPES
// ============================================================

#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum Bit { B0, B1 }

impl Bit {
    pub fn neg(self) -> Bit { match self { Bit::B0 => Bit::B1, Bit::B1 => Bit::B0 } }
    pub fn and(self, b: Bit) -> Bit { match (self, b) { (Bit::B1, Bit::B1) => Bit::B1, _ => Bit::B0 } }
    pub fn or(self, b: Bit) -> Bit { match (self, b) { (Bit::B0, Bit::B0) => Bit::B0, _ => Bit::B1 } }
    pub fn to_int(self) -> u8 { match self { Bit::B0 => 0, Bit::B1 => 1 } }
    pub fn from_int(n: u8) -> Self { if n == 0 { Bit::B0 } else { Bit::B1 } }
}

pub type Variable = usize;

#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum Literal { PosVar(Variable), NegVar(Variable) }

impl Literal {
    pub fn negate(self) -> Literal { match self { Literal::PosVar(v) => Literal::NegVar(v), Literal::NegVar(v) => Literal::PosVar(v) } }
    pub fn variable(self) -> Variable { match self { Literal::PosVar(v) | Literal::NegVar(v) => v } }
}

pub type Clause = Vec<Literal>;
pub type Formula = Vec<Clause>;
pub type Assignment = HashMap<Variable, Bit>;

// ============================================================
// II. BOOLEAN SEMANTICS
// ============================================================

pub fn eval_literal(lit: Literal, assign: &Assignment) -> Bit {
    match lit {
        Literal::PosVar(v) => *assign.get(&v).unwrap_or(&Bit::B0),
        Literal::NegVar(v) => assign.get(&v).unwrap_or(&Bit::B0).neg(),
    }
}

pub fn eval_clause(clause: &Clause, assign: &Assignment) -> Bit {
    clause.iter().fold(Bit::B0, |acc, &lit| acc.or(eval_literal(lit, assign)))
}

pub fn eval_formula(formula: &Formula, assign: &Assignment) -> Bit {
    formula.iter().fold(Bit::B1, |acc, clause| acc.and(eval_clause(clause, assign)))
}

pub fn is_satisfiable(formula: &Formula, assign: &Assignment) -> bool {
    eval_formula(formula, assign) == Bit::B1
}

// ============================================================
// III. 3-SAT
// ============================================================

pub fn is_3clause(clause: &Clause) -> bool { clause.len() <= 3 }
pub fn is_3cnf(formula: &Formula) -> bool { formula.iter().all(|c| is_3clause(c)) }

// ============================================================
// IV. CERTIFICATE VERIFIER
// ============================================================

#[derive(Clone, Debug)]
pub struct Certificate { pub formula: Formula, pub assignment: Assignment }

pub fn verify_3sat(cert: &Certificate) -> bool {
    is_3cnf(&cert.formula) && is_satisfiable(&cert.formula, &cert.assignment)
}

// ============================================================
// V. SAT → 3-SAT
// ============================================================

pub fn transform_clause(clause: &Clause, next_var: &mut Variable) -> Formula {
    match clause.len() {
        0 => vec![],
        1..=3 => vec![clause.clone()],
        _ => {
            let mut result = Formula::new();
            let mut remaining: Vec<Literal> = clause.clone();
            while remaining.len() > 3 {
                let l1 = remaining.remove(0);
                let l2 = remaining.remove(0);
                let l3 = remaining.remove(0);
                let aux = Literal::PosVar(*next_var);
                *next_var += 1;
                result.push(vec![l1, l2, aux]);
                remaining.insert(0, Literal::NegVar(aux.variable()));
                remaining.insert(1, l3);
            }
            result.push(remaining);
            result
        }
    }
}

pub fn sat_to_3sat(formula: &Formula) -> Formula {
    let mut next_var = formula.iter().flat_map(|c| c.iter()).map(|l| l.variable()).max().unwrap_or(0) + 1;
    formula.iter().flat_map(|c| transform_clause(c, &mut next_var)).collect()
}

// ============================================================
// VI. CIRCUITS
// ============================================================

#[derive(Clone, Debug)]
pub enum Circuit { InputGate(Variable), AndGate(Box<Circuit>, Box<Circuit>), OrGate(Box<Circuit>, Box<Circuit>), NotGate(Box<Circuit>) }

pub fn eval_circuit(circuit: &Circuit, assign: &Assignment) -> Bit {
    match circuit {
        Circuit::InputGate(v) => *assign.get(v).unwrap_or(&Bit::B0),
        Circuit::AndGate(g1, g2) => eval_circuit(g1, assign).and(eval_circuit(g2, assign)),
        Circuit::OrGate(g1, g2) => eval_circuit(g1, assign).or(eval_circuit(g2, assign)),
        Circuit::NotGate(g) => eval_circuit(g, assign).neg(),
    }
}

pub fn circuit_sat(circuit: &Circuit, assign: &Assignment) -> bool { eval_circuit(circuit, assign) == Bit::B1 }

// ============================================================
// VII. TSEITIN TRANSFORMATION
// ============================================================

pub fn tseitin(circuit: &Circuit) -> (Formula, Variable) {
    let mut formula = Formula::new();
    let mut next_var = 0usize;
    go(circuit, &mut formula, &mut next_var);
    (formula, next_var)
}

fn go(circuit: &Circuit, formula: &mut Formula, next_var: &mut Variable) -> Variable {
    match circuit {
        Circuit::InputGate(v) => *v,
        Circuit::NotGate(g) => {
            let v = go(g, formula, next_var);
            let aux = *next_var; *next_var += 1;
            formula.push(vec![Literal::NegVar(aux), Literal::NegVar(v)]);
            formula.push(vec![Literal::PosVar(aux), Literal::PosVar(v)]);
            aux
        }
        Circuit::AndGate(g1, g2) => {
            let v1 = go(g1, formula, next_var);
            let v2 = go(g2, formula, next_var);
            let aux = *next_var; *next_var += 1;
            formula.push(vec![Literal::NegVar(aux), Literal::PosVar(v1)]);
            formula.push(vec![Literal::NegVar(aux), Literal::PosVar(v2)]);
            formula.push(vec![Literal::PosVar(aux), Literal::NegVar(v1), Literal::NegVar(v2)]);
            aux
        }
        Circuit::OrGate(g1, g2) => {
            let v1 = go(g1, formula, next_var);
            let v2 = go(g2, formula, next_var);
            let aux = *next_var; *next_var += 1;
            formula.push(vec![Literal::NegVar(aux), Literal::PosVar(v1), Literal::PosVar(v2)]);
            formula.push(vec![Literal::PosVar(aux), Literal::NegVar(v1)]);
            formula.push(vec![Literal::PosVar(aux), Literal::NegVar(v2)]);
            aux
        }
    }
}

// ============================================================
// VIII. SPECTRAL GAP
// ============================================================

pub fn log2(n: u64) -> u64 { if n <= 1 { 0 } else { 1 + log2(n / 2) } }
pub fn spectral_gap(kappa: u64, p: u64, n: u64) -> u64 { if n <= 1 { 0 } else { kappa * p / (log2(n) + 1) } }
pub fn mixing_time(gamma: u64) -> u64 { if gamma == 0 { 0 } else { 1 / gamma + 1 } }

// ============================================================
// IX. WICK ROTATION
// ============================================================

#[derive(Clone, Copy, Debug)]
pub struct Complex { pub re: f64, pub im: f64 }

pub fn wick_rotate(t: f64) -> Complex { Complex { re: 0.0, im: t } }
pub fn euclidean_norm(c: Complex) -> f64 { c.re * c.re + c.im * c.im }

// ============================================================
// X. WORM LEDGER
// ============================================================

#[derive(Clone, Debug)]
pub struct WORMBlock { pub block_index: u64, pub timestamp: i64, pub agent_id: String, pub strategy: u32, pub state_hash: u64, pub prev_hash: u64 }

pub fn valid_chain(blocks: &[WORMBlock]) -> bool {
    blocks.windows(2).all(|w| w[1].prev_hash == w[0].state_hash)
}

// ============================================================
// XI. SOVEREIGN CONSTANTS
// ============================================================

pub const THETA_NUM: u64 = 89;
pub const THETA_DEN: u64 = 2462;
pub const THETA: f64 = 89.0 / 2462.0;
pub const T0_DEFAULT: f64 = 0.1;
pub const ALPHA_DEFAULT: f64 = 2.0;
pub const H_MAX: f64 = 0.20;
pub const THRESHOLD: f64 = 512.0;
pub const T_UPPER_BOUND: f64 = 0.2218;
pub const S_LOWER_BOUND: f64 = 90.75;
pub const D_MIN: f64 = 1.0;

// ============================================================
// XII. FREE ENERGY
// ============================================================

pub fn free_energy(t0: f64, log_z: f64) -> f64 { t0 * log_z }
pub fn optimal_t0() -> f64 { THETA }
pub fn nc_torus_phase(n: u64) -> f64 { (2.0 * std::f64::consts::PI * THETA * n as f64).cos() }

// ============================================================
// XIII. P vs NP STATUS
// ============================================================

pub const P_VS_NP_STATUS: &str = "UNRESOLVED";

#[cfg(test)]
mod tests {
    use super::*;
    #[test] fn test_bit_neg() { assert_eq!(Bit::B0.neg(), Bit::B1); assert_eq!(Bit::B1.neg(), Bit::B0); }
    #[test] fn test_bit_and() { assert_eq!(Bit::B1.and(Bit::B1), Bit::B1); assert_eq!(Bit::B1.and(Bit::B0), Bit::B0); }
    #[test] fn test_bit_or() { assert_eq!(Bit::B0.or(Bit::B0), Bit::B0); assert_eq!(Bit::B0.or(Bit::B1), Bit::B1); }
    #[test] fn test_theta() { assert!((THETA - 89.0 / 2462.0).abs() < 1e-10); }
    #[test] fn test_spectral_gap() { assert!(spectral_gap(1, 10, 1024) > 0); }
    #[test] fn test_wick() { let c = wick_rotate(1.0); assert_eq!(c.re, 0.0); assert_eq!(c.im, 1.0); }
    #[test] fn test_valid_chain() { let b1 = WORMBlock { block_index: 0, timestamp: 0, agent_id: "a".into(), strategy: 1, state_hash: 123, prev_hash: 0 }; let b2 = WORMBlock { block_index: 1, timestamp: 1, agent_id: "b".into(), strategy: 2, state_hash: 456, prev_hash: 123 }; assert!(valid_chain(&[b1, b2])); }
}
