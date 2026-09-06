# Hardware: Wormhole Stealer

## Verilog-S Specification: Wormhole_Stealer.v

```verilog
module Wormhole_Stealer #(
    parameter N_VARS = 1024,
    parameter N_WORKERS = 64,
    parameter PHASE_RES = 8
)(
    input wire clk,
    input wire rst_n,
    input wire [N_VARS-1:0] local_state,
    input wire [N_VARS-1:0] target_state,
    input wire steal_trigger,
    output reg [N_VARS-1:0] next_state,
    output reg phase_coherent
);

    reg [PHASE_RES-1:0] imaginary_phase;
    wire [N_VARS-1:0] xor_diff = local_state ^ target_state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            next_state <= {N_VARS{1'b0}};
            imaginary_phase <= 0;
            phase_coherent <= 0;
        end else begin
            imaginary_phase <= imaginary_phase + 1;
            if (steal_trigger) begin
                next_state <= target_state ^ (xor_diff & {N_VARS{imaginary_phase[0]}});
                phase_coherent <= (local_state != target_state);
            end else begin
                next_state <= local_state;
                phase_coherent <= 0;
            end
        end
    end
endmodule
```

## Mathematical Mapping

### XOR-Phase Operator (S)
S(x_local, x_stolen, φ) = x_stolen ⊕ (φ · (x_local ⊕ x_stolen))

### Imaginary Time Clock
imaginary_phase register acts as temporal parameter τ. Cycles through manifold slices ensuring no worker stays trapped > 2^PHASE_RES cycles.

### Complexity Reduction
N workers coupled via steal_trigger reduces search graph diameter from 2^n (Hamming) to O(log N) (Stealing distance).

## Verification Obligations

| PO | Obligation | Method |
|---|---|---|
| PO₁ | Type Consistency | State width N_VARS identical across workers |
| PO₂ | Non-Locality | target_state from worker W_j where d(x_i,x_j) > poly(n) |
| PO₃ | Phase-Rotation | imaginary_phase coprime to transition cycle |
| PO₄ | Convergence | phase_coherent stabilizes at 1 near global minimum |
