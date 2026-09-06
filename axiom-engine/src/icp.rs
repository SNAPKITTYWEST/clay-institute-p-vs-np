// ============================================================
// ICP: Integrity Constraint Governance Protocol
// Rust implementation
// ============================================================

use std::collections::HashMap;

#[derive(Clone, Debug, PartialEq, Eq)]
pub enum ICPStatus { Initialized, Governing, Verified, Failed, Halted, Emergency }

#[derive(Clone, Debug, PartialEq, Eq)]
pub enum ClaimState { Unknown, Observed, Derived, Proven, Contradicted, Abstained }

#[derive(Clone, Debug, PartialEq, Eq)]
pub enum ActorState { Registered, Authorized, Revoked }

#[derive(Clone, Debug)]
pub struct ICPState {
    pub version: String, pub level: u32, pub status: ICPStatus,
    pub authority: u32, pub policies: u32, pub constraints: u32,
    pub claims: u32, pub evidence: u32, pub decisions: u32,
    pub executions: u32, pub failures: u32,
}

impl ICPState {
    pub fn init() -> Self {
        ICPState { version: "GOV-1.0".into(), level: 99, status: ICPStatus::Initialized,
            authority: 0, policies: 0, constraints: 0, claims: 0,
            evidence: 0, decisions: 0, executions: 0, failures: 0 }
    }
    pub fn halt(&mut self, reason: &str) { self.status = ICPStatus::Halted; self.failures += 1; eprintln!("ICP HALT: {}", reason); }
    pub fn fail(&mut self, reason: &str) { self.status = ICPStatus::Failed; self.failures += 1; eprintln!("ICP FAIL: {}", reason); }
}

#[derive(Clone, Debug)]
pub struct Actor { pub id: String, pub typ: String, pub scope: String, pub state: ActorState }

#[derive(Clone, Debug)]
pub struct Policy { pub id: String, pub text: String, pub level: u32, pub state: String }

#[derive(Clone, Debug)]
pub struct Constraint { pub id: String, pub text: String, pub typ: String, pub state: String }

#[derive(Clone, Debug)]
pub struct Claim { pub id: String, pub text: String, pub actor: String, pub state: ClaimState, pub provenance: Option<String> }

#[derive(Clone, Debug)]
pub struct Evidence { pub id: String, pub data: String, pub source: String }

#[derive(Clone, Debug)]
pub struct Decision { pub id: String, pub claim_id: String, pub action: String, pub state: String }

#[derive(Clone, Debug)]
pub struct Execution { pub id: String, pub actor: String, pub state: String }

#[derive(Clone, Debug)]
pub struct Seal { pub decision_id: String, pub status: String, pub level: u32 }

pub type DAG = HashMap<(String, String), String>;

pub fn check_claim(claim: &Claim) -> bool {
    match claim.state {
        ClaimState::Contradicted | ClaimState::Unknown | ClaimState::Abstained => false,
        ClaimState::Observed | ClaimState::Derived | ClaimState::Proven => claim.provenance.is_some(),
    }
}

pub fn enforce_claim(claim: &Claim) -> bool { check_claim(claim) }

pub fn verify_dual(dag: &DAG) -> u32 {
    let mut violations = 0u32;
    for ((kind, from, _), to) in dag {
        if kind == "GOTO" && !dag.contains_key(&("COME-FROM".into(), to.clone(), from.clone())) {
            violations += 1;
        }
    }
    violations
}

pub const THETA: f64 = 89.0 / 2462.0;
pub const P_VS_NP_STATUS: &str = "UNRESOLVED";

#[cfg(test)]
mod tests {
    use super::*;
    #[test] fn test_icp_init() { let s = ICPState::init(); assert_eq!(s.status, ICPStatus::Initialized); }
    #[test] fn test_check_proven() { let c = Claim { id: "C1".into(), text: "t".into(), actor: "S".into(), state: ClaimState::Proven, provenance: Some("A".into()) }; assert!(check_claim(&c)); }
    #[test] fn test_check_unknown() { let c = Claim { id: "C1".into(), text: "t".into(), actor: "S".into(), state: ClaimState::Unknown, provenance: None }; assert!(!check_claim(&c)); }
}
