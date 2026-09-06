# Hardware: ATLAS Orchestrator

## SystemVerilog: ATLAS_Orchestrator.sv

```systemverilog
module ATLAS_Orchestrator #(
    parameter N_WORKERS = 64,
    parameter REWIRE_PROB = 8'h2A
)(
    input logic clk,
    input logic rst_n,
    input logic [N_WORKERS-1:0] worker_busy,
    input logic [N_WORKERS-1:0] worker_stuck,
    output logic [N_WORKERS-1:0][N_WORKERS-1:0] steal_matrix,
    output logic [N_WORKERS-1:0] global_steal_trigger
);

    logic [15:0] lfsr;
    logic [N_WORKERS-1:0] routing_table [N_WORKERS];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lfsr <= 16'hACE1;
            global_steal_trigger <= '0;
            steal_matrix <= '0;
        end else begin
            lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
            for (int i = 0; i < N_WORKERS; i++) begin
                if (lfsr[7:0] < REWIRE_PROB) begin
                    routing_table[i] = lfsr[5:0];
                end else begin
                    routing_table[i] = (i + 1) % N_WORKERS;
                end
            end
            for (int i = 0; i < N_WORKERS; i++) begin
                if (worker_stuck[i]) begin
                    int target = routing_table[i];
                    steal_matrix[target][i] <= 1'b1;
                    global_steal_trigger[target] <= 1'b1;
                end
            end
        end
    end
endmodule
```

## Mathematical Formalization

### Topology Transition
Ring Lattice → Small-World Graph:
- Lattice path length: L ≈ N/4
- Small-World path length: L ≈ ln N / ln ⟨k⟩

### Stealing Operator as Laplacian
steal_matrix defines Graph Laplacian L_ATLAS. State evolution:

∂ψ/∂τ = -L_ATLAS · ψ

Large spectral gap → faster mixing time → polynomial hitting time.

### Sovereign Control Loop
Trigger(W_j, W_i) = Sovereign(Stuck(W_i) ∧ Idle(W_j))
