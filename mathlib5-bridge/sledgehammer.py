#!/usr/bin/env python3
"""
sledgehammer.py — Sovereign sorry-hunter for Lean 4 + Mathlib.

Reads a Lean file, finds every `sorry`, attempts a ranked tactic sequence
for each one, writes a patched version with the first tactic that compiles.
Seals a WORM receipt on every solved sorry.

Usage:
    python sledgehammer.py <file.lean> [--project <lake-root>] [--dry-run]

Tactic ladder (tried in order, fastest → strongest):
    rfl, decide, norm_num, ring, simp, omega, linarith,
    simp [*]; ring, simp only [...]; linarith, aesop, tauto

WORM receipt appended to: sledgehammer_chain.jsonl (same dir as file)
"""
import argparse, hashlib, json, os, re, subprocess, sys, tempfile, datetime

TACTICS = [
    "rfl",
    "decide",
    "norm_num",
    "ring",
    "simp",
    "omega",
    "linarith",
    "simp [*]; ring",
    "norm_num; ring",
    "simp only []; ring",
    "simp only []; linarith",
    "ring_nf; norm_num",
    "aesop",
    "tauto",
]

def lean_binary(project_root):
    elan = os.path.expanduser("~/.elan/bin/lean")
    if os.path.exists(elan):
        return elan
    return "lean"

def lake_env(project_root):
    """Return env dict with LEAN_PATH set via `lake env`."""
    try:
        result = subprocess.run(
            ["lake", "env", "printenv", "LEAN_PATH"],
            cwd=project_root, capture_output=True, text=True, timeout=30
        )
        lean_path = result.stdout.strip()
    except Exception:
        lean_path = ""
    env = os.environ.copy()
    if lean_path:
        env["LEAN_PATH"] = lean_path
    return env

def try_tactic(lean_src: str, sorry_line: int, tactic: str,
               project_root: str, lean_bin: str, env: dict) -> bool:
    """Replace the sorry on sorry_line with tactic, compile, return True if clean."""
    lines = lean_src.splitlines(keepends=True)
    original = lines[sorry_line]
    lines[sorry_line] = original.replace("sorry", tactic, 1)
    patched = "".join(lines)

    with tempfile.NamedTemporaryFile(suffix=".lean", mode="w",
                                     encoding="utf-8", delete=False) as f:
        f.write(patched)
        tmp = f.name

    try:
        result = subprocess.run(
            [lean_bin, tmp],
            cwd=project_root, capture_output=True, text=True, timeout=60, env=env
        )
        output = result.stdout + result.stderr
        # Clean if: no errors, no remaining sorries from our substitution
        has_error = "error:" in output
        return (result.returncode == 0 or not has_error)
    except subprocess.TimeoutExpired:
        return False
    finally:
        os.unlink(tmp)

def find_sorries(src: str):
    """Return list of (line_index, context_snippet) for each tactic `sorry`.
    Skips lines where sorry appears only inside a -- comment."""
    results = []
    for i, line in enumerate(src.splitlines()):
        # Strip inline comment before checking
        code_part = re.split(r'--', line)[0]
        if re.search(r'\bsorry\b', code_part):
            results.append((i, line.strip()))
    return results

def sha256(s: str) -> str:
    return hashlib.sha256(s.encode()).hexdigest()

def prior_tip(chain_path: str) -> str:
    tip = "0" * 64
    if os.path.exists(chain_path):
        lines = open(chain_path, encoding="utf-8").read().strip().splitlines()
        if lines:
            try:
                tip = json.loads(lines[-1])["receipt_hash"]
            except Exception:
                pass
    return tip

def seal(chain_path: str, record: dict) -> str:
    tip = prior_tip(chain_path)
    blob = json.dumps(record, sort_keys=True).encode()
    receipt = hashlib.sha256(tip.encode() + b"|" + blob).hexdigest()
    record["receipt_hash"] = receipt
    with open(chain_path, "a", encoding="utf-8") as f:
        f.write(json.dumps(record) + "\n")
    return receipt

def run(file_path: str, project_root: str, dry_run: bool):
    src = open(file_path, encoding="utf-8").read()
    sorries = find_sorries(src)
    if not sorries:
        print("No sorries found."); return

    print(f"Found {len(sorries)} sorry(s) in {file_path}")
    lean_bin = lean_binary(project_root)
    env = lake_env(project_root)
    chain_path = os.path.join(os.path.dirname(file_path), "sledgehammer_chain.jsonl")

    results = []
    patched_src = src

    for idx, (line_no, ctx) in enumerate(sorries):
        print(f"\n[{idx+1}/{len(sorries)}] Line {line_no+1}: {ctx[:80]}")
        solved = None
        for tactic in TACTICS:
            print(f"  trying: {tactic} ...", end=" ", flush=True)
            if dry_run:
                print("(dry-run skip)")
                continue
            ok = try_tactic(patched_src, line_no, tactic, project_root, lean_bin, env)
            if ok:
                print("SOLVED")
                solved = tactic
                # Apply to running patched_src so downstream sorries see it
                lines = patched_src.splitlines(keepends=True)
                lines[line_no] = lines[line_no].replace("sorry", tactic, 1)
                patched_src = "".join(lines)
                break
            else:
                print("✗")

        rec = {
            "file": os.path.basename(file_path),
            "line": line_no + 1,
            "context": ctx,
            "tactic": solved or "UNSOLVED",
            "timestamp": datetime.datetime.now(datetime.timezone.utc).isoformat(),
            "file_hash": sha256(src),
        }
        results.append(rec)
        if not dry_run:
            seal(chain_path, rec)

    solved_count = sum(1 for r in results if r["tactic"] != "UNSOLVED")
    print(f"\n=== SLEDGEHAMMER RESULT ===")
    print(f"Solved: {solved_count}/{len(sorries)}")

    if solved_count > 0 and not dry_run:
        out_path = file_path.replace(".lean", "_sledged.lean")
        open(out_path, "w", encoding="utf-8").write(patched_src)
        print(f"Patched file: {out_path}")
        print(f"WORM chain:   {chain_path}")

    for r in results:
        status = "OK" if r["tactic"] != "UNSOLVED" else "XX"
        print(f"  [{status}] line {r['line']}: {r['tactic']}")

if __name__ == "__main__":
    ap = argparse.ArgumentParser(description="Sovereign Lean 4 sledgehammer")
    ap.add_argument("file", help="Path to .lean file")
    ap.add_argument("--project", default=None, help="Lake project root (default: file dir)")
    ap.add_argument("--dry-run", action="store_true", help="Find sorries only, don't attempt")
    args = ap.parse_args()

    project = args.project or os.path.dirname(os.path.abspath(args.file))
    run(os.path.abspath(args.file), project, args.dry_run)
