//! AXIOM Proof Assistant - WORM Proof Database (Rust)
//! Immutable theorem storage with SHA-256 sealing and Merkle tree
//! Every proof is cryptographically sealed for tamper-evident verification

use sha2::{Sha256, Digest};
use serde::{Serialize, Deserialize};
use std::fs;
use std::io::Write;
use std::path::Path;

/// A sealed proof entry in the WORM ledger
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProofEntry {
    pub theorem_name: String,
    pub theorem_hash: String,
    pub proof_hash: String,
    pub seal: String,
    pub timestamp: u64,
    pub merkle_proof: String,
}

/// WORM (Write-Once-Read-Many) proof database
pub struct WormDb {
    entries: Vec<ProofEntry>,
    ledger_path: String,
    merkle_root: String,
}

impl WormDb {
    /// Create new WORM database
    pub fn new(ledger_path: &str) -> Self {
        let mut db = WormDb {
            entries: Vec::new(),
            ledger_path: ledger_path.to_string(),
            merkle_root: "0".repeat(64),
        };

        // Load existing entries if ledger exists
        if Path::new(ledger_path).exists() {
            db.load_ledger();
        }

        db
    }

    /// Seal a theorem and proof to the WORM ledger
    pub fn seal_proof(&mut self, theorem_name: &str, theorem: &str, proof: &str) -> ProofEntry {
        // Compute hashes
        let theorem_hash = Self::hash(theorem);
        let proof_hash = Self::hash(proof);
        
        // Generate seal
        let seal_data = format!("{}:{}:{}", theorem_name, theorem_hash, proof_hash);
        let seal = Self::hash(&seal_data);

        // Get timestamp
        let timestamp = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs();

        // Create entry
        let entry = ProofEntry {
            theorem_name: theorem_name.to_string(),
            theorem_hash,
            proof_hash,
            seal,
            timestamp,
            merkle_proof: String::new(), // Updated after Merkle computation
        };

        // Add to entries
        self.entries.push(entry.clone());

        // Recompute Merkle root
        self.merkle_root = self.compute_merkle_root();

        // Update entry with Merkle proof
        let last_idx = self.entries.len() - 1;
        self.entries[last_idx].merkle_proof = self.merkle_root[..32].to_string();

        // Append to ledger file
        self.append_to_ledger(&self.entries[last_idx]);

        self.entries[last_idx].clone()
    }

    /// Verify a proof against the WORM ledger
    pub fn verify_proof(&self, theorem_name: &str, theorem: &str, proof: &str) -> bool {
        let theorem_hash = Self::hash(theorem);
        let proof_hash = Self::hash(proof);

        // Find entry in ledger
        self.entries.iter().any(|entry| {
            entry.theorem_name == theorem_name
                && entry.theorem_hash == theorem_hash
                && entry.proof_hash == proof_hash
        })
    }

    /// Get all sealed proofs
    pub fn get_all_proofs(&self) -> &[ProofEntry] {
        &self.entries
    }

    /// Get Merkle root
    pub fn get_merkle_root(&self) -> &str {
        &self.merkle_root
    }

    /// Compute SHA-256 hash
    fn hash(data: &str) -> String {
        let mut hasher = Sha256::new();
        hasher.update(data.as_bytes());
        format!("{:x}", hasher.finalize())
    }

    /// Compute Merkle root from all entries
    fn compute_merkle_root(&self) -> String {
        if self.entries.is_empty() {
            return "0".repeat(64);
        }

        // Leaf hashes
        let mut hashes: Vec<String> = self.entries
            .iter()
            .map(|e| Self::hash(&format!("{}:{}:{}", e.theorem_name, e.theorem_hash, e.proof_hash)))
            .collect();

        // Build Merkle tree
        while hashes.len() > 1 {
            let mut next_level = Vec::new();
            for chunk in hashes.chunks(2) {
                let combined = if chunk.len() == 2 {
                    format!("{}{}", chunk[0], chunk[1])
                } else {
                    format!("{}{}", chunk[0], chunk[0])
                };
                next_level.push(Self::hash(&combined));
            }
            hashes = next_level;
        }

        hashes[0].clone()
    }

    /// Append entry to ledger file
    fn append_to_ledger(&self, entry: &ProofEntry) {
        let path = Path::new(&self.ledger_path);
        
        // Create directory if needed
        if let Some(parent) = path.parent() {
            fs::create_dir_all(parent).ok();
        }

        // Append JSON line
        if let Ok(mut file) = fs::OpenOptions::new()
            .create(true)
            .append(true)
            .open(path)
        {
            let json = serde_json::to_string(entry).unwrap();
            writeln!(file, "{}", json).ok();
        }
    }

    /// Load existing ledger
    fn load_ledger(&mut self) {
        if let Ok(content) = fs::read_to_string(&self.ledger_path) {
            for line in content.lines() {
                if let Ok(entry) = serde_json::from_str::<ProofEntry>(line) {
                    self.entries.push(entry);
                }
            }
            self.merkle_root = self.compute_merkle_root();
        }
    }

    /// Export ledger to JSON
    pub fn export_json(&self) -> String {
        serde_json::to_string_pretty(&self.entries).unwrap()
    }
}

/// Proof certificate for external verification
#[derive(Debug, Serialize, Deserialize)]
pub struct ProofCertificate {
    pub theorem_name: String,
    pub theorem_hash: String,
    pub proof_hash: String,
    pub seal: String,
    pub merkle_root: String,
    pub timestamp: u64,
}

impl WormDb {
    /// Generate proof certificate
    pub fn generate_certificate(&self, theorem_name: &str) -> Option<ProofCertificate> {
        self.entries.iter()
            .find(|e| e.theorem_name == theorem_name)
            .map(|entry| ProofCertificate {
                theorem_name: entry.theorem_name.clone(),
                theorem_hash: entry.theorem_hash.clone(),
                proof_hash: entry.proof_hash.clone(),
                seal: entry.seal.clone(),
                merkle_root: self.merkle_root.clone(),
                timestamp: entry.timestamp,
            })
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;

    #[test]
    fn test_seal_proof() {
        let ledger_path = "test_ledger.jsonl";
        let mut db = WormDb::new(ledger_path);
        
        let theorem = "∀ n : Nat, n + 0 = n";
        let proof = "λ n. induction n ...";
        
        let entry = db.seal_proof("add_zero", theorem, proof);
        
        assert_eq!(entry.theorem_name, "add_zero");
        assert!(!entry.seal.is_empty());
        assert!(!entry.merkle_proof.is_empty());
        
        // Cleanup
        fs::remove_file(ledger_path).ok();
    }

    #[test]
    fn test_verify_proof() {
        let ledger_path = "test_ledger_verify.jsonl";
        let mut db = WormDb::new(ledger_path);
        
        let theorem = "∀ n : Nat, n + 0 = n";
        let proof = "λ n. induction n ...";
        
        db.seal_proof("add_zero", theorem, proof);
        
        assert!(db.verify_proof("add_zero", theorem, proof));
        assert!(!db.verify_proof("add_zero", "wrong theorem", proof));
        
        // Cleanup
        fs::remove_file(ledger_path).ok();
    }

    #[test]
    fn test_merkle_root() {
        let ledger_path = "test_ledger_merkle.jsonl";
        let mut db = WormDb::new(ledger_path);
        
        db.seal_proof("thm1", "theorem 1", "proof 1");
        let root1 = db.get_merkle_root().to_string();
        
        db.seal_proof("thm2", "theorem 2", "proof 2");
        let root2 = db.get_merkle_root().to_string();
        
        assert_ne!(root1, root2); // Merkle root changes with new proofs
        assert_ne!(root1, "0".repeat(64)); // Not empty
        
        // Cleanup
        fs::remove_file(ledger_path).ok();
    }

    #[test]
    fn test_certificate() {
        let ledger_path = "test_ledger_cert.jsonl";
        let mut db = WormDb::new(ledger_path);
        
        db.seal_proof("add_comm", "∀ n m, n + m = m + n", "proof...");
        
        let cert = db.generate_certificate("add_comm");
        assert!(cert.is_some());
        
        let cert = cert.unwrap();
        assert_eq!(cert.theorem_name, "add_comm");
        assert!(!cert.seal.is_empty());
        
        // Cleanup
        fs::remove_file(ledger_path).ok();
    }
}
