# Deployment: Blueprint & REST API

## Hardware Deployment Map

### Node Layer (Workers)
Each FPGA implements N Recursive-Core instances and one Wormhole_Stealer module.

### Orchestration Layer (ATLAS)
Dedicated master FPGA with ATLAS_Orchestrator.sv for Small-World routing.

### Verification Layer (AXIOM/LEDGE)
CPU-FPGA hybrid running Lean 4 verification kernel and WORM storage.

## REST API

| Endpoint | Method | Description |
|---|---|---|
| /api/v1/manifold/status | GET | Current temperature and phase of Wick-rotation |
| /api/v1/atlas/topology | GET | Small-World metrics (avg path len, clustering) |
| /api/v1/wormhole/trigger | POST | Manually inject non-local jump |
| /api/v1/ledger/verify | GET | Retrieve AXIOM-verified proof seal from WORM |

## Execution Sequence

1. **Initialize** — Load NP-hard instance into FPGA register arrays
2. **Heat** — Set T high (Random Walk phase), initialize imaginary_phase to 0
3. **Cool** — Decrease T while ATLAS rewires steal_matrix for Small-World connectivity
4. **Wormhole** — Trigger steal_trigger on local minimum → jump to distant state
5. **Converge** — Wave-front interferes constructively at x* → phase_coherent fires
6. **Seal** — AXIOM verifies τ_hit ≤ poly(n) → LEDGE seals to WORM chain
