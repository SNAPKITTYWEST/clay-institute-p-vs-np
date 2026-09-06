//! AXIOM Proof Assistant - Minimal Trusted Core (Rust)
//! Type checking, definitional equality, proof verification
//! ~500 lines - the smallest possible trusted kernel

use std::collections::HashMap;
use std::fmt;

/// Term: core AST representation
#[derive(Debug, Clone, PartialEq)]
pub enum Term {
    Var(String),
    Lam(String, Box<Term>, Box<Term>),      // λ(x : A). body
    Pi(String, Box<Term>, Box<Term>),       // Π(x : A). B
    App(Box<Term>, Box<Term>),              // f x
    Sigma(String, Box<Term>, Box<Term>),    // Σ(x : A). B
    Pair(Box<Term>, Box<Term>),             // (a, b)
    Proj(Box<Term>, usize),                 // π₁(p) or π₂(p)
    Type(u32),                              // Type i (universe)
    Inductive(String, u32),                 // Inductive type at universe level
    Constructor(String, Box<Term>),         // Constructor with result type
    Recursor(String, Box<Term>, Box<Term>), // Recursor for inductive type
}

/// Typing environment
#[derive(Debug, Clone, Default)]
pub struct Env {
    bindings: HashMap<String, (Term, Option<Term>)>, // (type, value?)
}

impl Env {
    pub fn new() -> Self {
        Env {
            bindings: HashMap::new(),
        }
    }

    pub fn extend(&mut self, name: String, typ: Term, value: Option<Term>) {
        self.bindings.insert(name, (typ, value));
    }

    pub fn lookup(&self, name: &str) -> Option<&(Term, Option<Term>)> {
        self.bindings.get(name)
    }

    pub fn remove(&mut self, name: &str) {
        self.bindings.remove(name);
    }
}

/// Type checking error
#[derive(Debug)]
pub enum TypeError {
    UnboundVariable(String),
    TypeMismatch { expected: Term, found: Term },
    NotAFunction(Term),
    NotAPair(Term),
    InvalidProjection,
    UniverseMismatch { expected: u32, found: u32 },
}

impl fmt::Display for TypeError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            TypeError::UnboundVariable(name) => write!(f, "Unbound variable: {}", name),
            TypeError::TypeMismatch { expected, found } => {
                write!(f, "Type mismatch:\n  expected: {:?}\n  found: {:?}", expected, found)
            }
            TypeError::NotAFunction(t) => write!(f, "Not a function: {:?}", t),
            TypeError::NotAPair(t) => write!(f, "Not a pair: {:?}", t),
            TypeError::InvalidProjection => write!(f, "Invalid projection"),
            TypeError::UniverseMismatch { expected, found } => {
                write!(f, "Universe mismatch: expected Type {}, found Type {}", expected, found)
            }
        }
    }
}

/// Type inference: compute the type of a term
pub fn infer(env: &Env, term: &Term) -> Result<Term, TypeError> {
    match term {
        Term::Var(name) => {
            env.lookup(name)
                .map(|(typ, _)| typ.clone())
                .ok_or_else(|| TypeError::UnboundVariable(name.clone()))
        }

        Term::Lam(name, arg_type, body) => {
            // λ(x : A). body : Π(x : A). B where body : B
            let mut env_ext = env.clone();
            env_ext.extend(name.clone(), *arg_type.clone(), None);
            let body_type = infer(&env_ext, body)?;
            Ok(Term::Pi(name.clone(), arg_type.clone(), Box::new(body_type)))
        }

        Term::Pi(_, arg_type, body) => {
            // Π(x : A). B : Type (max i j) where A : Type i, B : Type j
            let arg_type_type = infer(env, arg_type)?;
            let arg_level = match arg_type_type {
                Term::Type(level) => level,
                _ => return Err(TypeError::UniverseMismatch { expected: 0, found: 0 }),
            };

            let mut env_ext = env.clone();
            env_ext.extend("_".to_string(), *arg_type.clone(), None);
            let body_type = infer(&env_ext, body)?;
            let body_level = match body_type {
                Term::Type(level) => level,
                _ => return Err(TypeError::UniverseMismatch { expected: 0, found: 0 }),
            };

            Ok(Term::Type(arg_level.max(body_level)))
        }

        Term::App(func, arg) => {
            // f x : B[x/y] where f : Π(y : A). B and x : A
            let func_type = infer(env, func)?;
            match func_type {
                Term::Pi(param_name, param_type, body) => {
                    check(env, arg, &param_type)?;
                    Ok(substitute(&body, &param_name, arg))
                }
                _ => Err(TypeError::NotAFunction(func_type)),
            }
        }

        Term::Sigma(_, fst_type, snd_type) => {
            // Σ(x : A). B : Type (max i j)
            let fst_type_type = infer(env, fst_type)?;
            let fst_level = match fst_type_type {
                Term::Type(level) => level,
                _ => return Err(TypeError::UniverseMismatch { expected: 0, found: 0 }),
            };

            let mut env_ext = env.clone();
            env_ext.extend("_".to_string(), *fst_type.clone(), None);
            let snd_type_type = infer(&env_ext, snd_type)?;
            let snd_level = match snd_type_type {
                Term::Type(level) => level,
                _ => return Err(TypeError::UniverseMismatch { expected: 0, found: 0 }),
            };

            Ok(Term::Type(fst_level.max(snd_level)))
        }

        Term::Pair(fst, snd) => {
            // (a, b) : Σ(x : A). B where a : A and b : B[a/x]
            let fst_type = infer(env, fst)?;
            let snd_type = infer(env, snd)?;
            Ok(Term::Sigma("_".to_string(), Box::new(fst_type), Box::new(snd_type)))
        }

        Term::Proj(pair, idx) => {
            // π₁(p) : A where p : Σ(x : A). B
            // π₂(p) : B[p.1/x]
            let pair_type = infer(env, pair)?;
            match pair_type {
                Term::Sigma(_, fst_type, snd_type) => {
                    if *idx == 1 {
                        Ok(*fst_type)
                    } else if *idx == 2 {
                        // TODO: substitute fst into snd_type
                        Ok(*snd_type)
                    } else {
                        Err(TypeError::InvalidProjection)
                    }
                }
                _ => Err(TypeError::NotAPair(pair_type)),
            }
        }

        Term::Type(level) => {
            // Type i : Type (i + 1)
            Ok(Term::Type(level + 1))
        }

        Term::Inductive(_, level) => {
            // Nat : Type 0
            Ok(Term::Type(*level))
        }

        Term::Constructor(_, result_type) => {
            // zero : Nat
            Ok(*result_type.clone())
        }

        Term::Recursor(_, motive, _major) => {
            // Recursor returns motive applied to major
            Ok(*motive.clone())
        }
    }
}

/// Type checking: verify term has given type
pub fn check(env: &Env, term: &Term, expected: &Term) -> Result<(), TypeError> {
    let inferred = infer(env, term)?;
    if def_eq(env, &inferred, expected) {
        Ok(())
    } else {
        Err(TypeError::TypeMismatch {
            expected: expected.clone(),
            found: inferred,
        })
    }
}

/// Definitional equality: check if two terms are definitionally equal
pub fn def_eq(env: &Env, t1: &Term, t2: &Term) -> bool {
    // Try beta reduction
    let t1_norm = normalize(env, t1);
    let t2_norm = normalize(env, t2);

    struct_eq(&t1_norm, &t2_norm)
}

/// Structural equality
fn struct_eq(t1: &Term, t2: &Term) -> bool {
    match (t1, t2) {
        (Term::Var(n1), Term::Var(n2)) => n1 == n2,
        (Term::Lam(_n1, a1, b1), Term::Lam(_n2, a2, b2)) => {
            struct_eq(a1, a2) && struct_eq(b1, b2)
        }
        (Term::Pi(n1, a1, b1), Term::Pi(n2, a2, b2)) => {
            n1 == n2 && struct_eq(a1, a2) && struct_eq(b1, b2)
        }
        (Term::App(f1, x1), Term::App(f2, x2)) => {
            struct_eq(f1, f2) && struct_eq(x1, x2)
        }
        (Term::Type(l1), Term::Type(l2)) => l1 == l2,
        (Term::Inductive(n1, l1), Term::Inductive(n2, l2)) => {
            n1 == n2 && l1 == l2
        }
        (Term::Constructor(n1, t1), Term::Constructor(n2, t2)) => {
            n1 == n2 && struct_eq(t1, t2)
        }
        _ => false,
    }
}

/// Normalize term (beta reduction)
fn normalize(env: &Env, term: &Term) -> Term {
    match term {
        Term::App(func, arg) => {
            let func_norm = normalize(env, func);
            let arg_norm = normalize(env, arg);
            match func_norm {
                Term::Lam(param, _, body) => {
                    let substituted = substitute(&body, &param, &arg_norm);
                    normalize(env, &substituted)
                }
                _ => Term::App(Box::new(func_norm), Box::new(arg_norm)),
            }
        }
        Term::Lam(name, arg_type, body) => {
            Term::Lam(name.clone(), arg_type.clone(), Box::new(normalize(env, body)))
        }
        Term::Var(name) => {
            if let Some((_, Some(value))) = env.lookup(name) {
                normalize(env, value)
            } else {
                term.clone()
            }
        }
        _ => term.clone(),
    }
}

/// Substitute variable in term
fn substitute(term: &Term, var: &str, replacement: &Term) -> Term {
    match term {
        Term::Var(name) if name == var => replacement.clone(),
        Term::Var(_) => term.clone(),
        Term::Lam(name, arg_type, body) if name != var => {
            Term::Lam(
                name.clone(),
                Box::new(substitute(arg_type, var, replacement)),
                Box::new(substitute(body, var, replacement)),
            )
        }
        Term::Pi(name, arg_type, body) if name != var => {
            Term::Pi(
                name.clone(),
                Box::new(substitute(arg_type, var, replacement)),
                Box::new(substitute(body, var, replacement)),
            )
        }
        Term::App(func, arg) => {
            Term::App(
                Box::new(substitute(func, var, replacement)),
                Box::new(substitute(arg, var, replacement)),
            )
        }
        _ => term.clone(),
    }
}

/// Verify a proof term
pub fn verify_proof(env: &Env, theorem: &Term, proof: &Term) -> Result<(), TypeError> {
    check(env, proof, theorem)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_var_type() {
        let mut env = Env::new();
        env.extend("x".to_string(), Term::Type(0), None);
        let result = infer(&env, &Term::Var("x".to_string()));
        assert!(result.is_ok());
    }

    #[test]
    fn test_lambda_type() {
        let env = Env::new();
        let nat = Term::Inductive("Nat".to_string(), 0);
        let lam = Term::Lam(
            "x".to_string(),
            Box::new(nat.clone()),
            Box::new(Term::Var("x".to_string())),
        );
        let result = infer(&env, &lam);
        assert!(result.is_ok());
    }

    #[test]
    fn test_pi_type() {
        let env = Env::new();
        let nat = Term::Inductive("Nat".to_string(), 0);
        let pi = Term::Pi(
            "x".to_string(),
            Box::new(nat.clone()),
            Box::new(Term::Type(0)),
        );
        let result = infer(&env, &pi);
        assert!(result.is_ok());
        assert_eq!(result.unwrap(), Term::Type(1));
    }

    #[test]
    fn test_app_type() {
        let env = Env::new();
        let nat = Term::Inductive("Nat".to_string(), 0);
        let id_fn = Term::Lam(
            "x".to_string(),
            Box::new(nat.clone()),
            Box::new(Term::Var("x".to_string())),
        );
        let zero = Term::Constructor("zero".to_string(), Box::new(nat.clone()));
        let app = Term::App(Box::new(id_fn), Box::new(zero));
        let result = infer(&env, &app);
        assert!(result.is_ok());
    }

    #[test]
    fn test_def_eq() {
        let env = Env::new();
        let t1 = Term::Var("x".to_string());
        let t2 = Term::Var("x".to_string());
        assert!(def_eq(&env, &t1, &t2));
    }

    #[test]
    fn test_beta_reduction() {
        let env = Env::new();
        let nat = Term::Inductive("Nat".to_string(), 0);
        let lam = Term::Lam(
            "x".to_string(),
            Box::new(nat.clone()),
            Box::new(Term::Var("x".to_string())),
        );
        let zero = Term::Constructor("zero".to_string(), Box::new(nat.clone()));
        let app = Term::App(Box::new(lam), Box::new(zero.clone()));
        let normalized = normalize(&env, &app);
        assert_eq!(normalized, zero);
    }
}
