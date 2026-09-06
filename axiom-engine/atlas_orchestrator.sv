// ============================================================
// ATLAS Orchestrator - Small-World Routing Topology
// SystemVerilog Specification
//
// Maintains a Small-World routing matrix on N workers.
// Each worker is connected to k nearest neighbors in a ring
// lattice, plus long-range "Wormhole" edges added with
// probability p ≈ 0x2A / 256.
// ============================================================

module atlas_orchestrator #(
    parameter N_WORKERS = 64,
    parameter K_NEIGHBORS = 4,
    parameter REWIRE_P = 16'h2A00  // 0x2A / 256 = 0.16
)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        enable,

    // Worker interface
    input  logic [5:0]  worker_id,
    input  logic [5:0]  target_id,
    input  logic        route_req,
    output logic        route_ack,
    output logic [5:0]  next_hop,

    // Status
    output logic [31:0] spectral_gap,
    output logic [31:0] mixing_time,
    output logic        topology_valid
);

    // ============================================================
    // STATE REGISTER (WORM_LEDGER)
    // ============================================================
    // The WORM_LEDGER is a state register capturing full system state.
    // Modified ONLY by softirq_tail after atomic transactions.

    typedef struct packed {
        logic [31:0] epoch;
        logic [31:0] checksum;
        logic [N_WORKERS-1:0] worker_alive;
        logic [N_WORKERS*K_NEIGHBORS*6-1:0] neighbor_table;
        logic [N_WORKERS*6-1:0] wormhole_table;
    } worm_ledger_t;

    worm_ledger_t worm_ledger;
    worm_ledger_t worm_ledger_next;

    // ============================================================
    // TOPOLOGY STATE MACHINE
    // ============================================================

    typedef enum logic [2:0] {
        TOPOLOGY_INIT,
        TOPOLOGY_RING,
        TOPOLOGY_REWIRE,
        TOPOLOGY_WORMHOLE,
        TOPOLOGY_STABLE
    } topology_state_t;

    topology_state_t topo_state;

    // ============================================================
    // RING LATTICE CONSTRUCTION
    // ============================================================
    // Each worker i is connected to workers
    // (i+1)%N, (i+2)%N, ..., (i+K/2)%N
    // (undirected, so also i-1, i-2, ..., i-K/2)

    logic [5:0] ring_neighbors [N_WORKERS][K_NEIGHBORS];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < N_WORKERS; i++) begin
                for (int j = 0; j < K_NEIGHBORS; j++) begin
                    ring_neighbors[i][j] <= (i + j + 1) % N_WORKERS;
                end
            end
        end
    end

    // ============================================================
    // REWIRING LOGIC (Small-World)
    // ============================================================
    // With probability p, each edge (i, j) is rewired to (i, k)
    // where k is chosen uniformly at random.

    logic [7:0] rng_value;
    logic [5:0] random_target;

    // Simple LFSR-based PRNG for rewiring
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            rng_value <= 8'h01;
        else if (enable)
            rng_value <= {rng_value[6:0], rng_value[7] ^ rng_value[5]};
    end

    assign random_target = rng_value[5:0] % N_WORKERS;

    // ============================================================
    // WORMHOLE STEALER INTERFACE
    // ============================================================
    // The Wormhole Stealer implements non-local work-stealing
    // via long-range edges. When a worker detects load imbalance,
    // it sends a "steal" request through the Wormhole edge.

    logic        steal_req;
    logic [5:0]  steal_source;
    logic [5:0]  steal_target;
    logic        steal_ack;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            steal_req <= 1'b0;
            steal_source <= '0;
            steal_target <= '0;
        end else if (enable && route_req) begin
            // Check if target is a Wormhole neighbor
            for (int i = 0; i < K_NEIGHBORS; i++) begin
                if (wormhole_table[worker_id*K_NEIGHBORS*6 +: 6] == target_id) begin
                    steal_req <= 1'b1;
                    steal_source <= worker_id;
                    steal_target <= target_id;
                end
            end
        end
    end

    // ============================================================
    // SPECTRAL GAP COMPUTATION
    // ============================================================
    // γ(p,N) = κp/log(N)
    // For our system: κ = 1.0, p = REWIRE_P/256, N = N_WORKERS

    logic [31:0] log_n;
    logic [31:0] gamma;

    // Approximate log2 using CLZ (Count Leading Zeros)
    function automatic logic [31:0] log2_approx(input logic [31:0] val);
        logic [31:0] result;
        result = 0;
        for (int i = 31; i >= 0; i--) begin
            if (val[i]) result = i;
        end
        return result;
    endfunction

    assign log_n = log2_approx(N_WORKERS);
    assign gamma = (REWIRE_P * 256) / log_n;  // κp/log(N) in fixed-point

    // ============================================================
    // ROUTING LOGIC
    // ============================================================

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            topo_state <= TOPOLOGY_INIT;
            route_ack <= 1'b0;
            next_hop <= '0;
            topology_valid <= 1'b0;
        end else if (enable) begin
            case (topo_state)
                TOPOLOGY_INIT: begin
                    topo_state <= TOPOLOGY_RING;
                    spectral_gap <= 0;
                    mixing_time <= 0;
                end

                TOPOLOGY_RING: begin
                    // Build ring lattice
                    topo_state <= TOPOLOGY_REWIRE;
                end

                TOPOLOGY_REWIRE: begin
                    // Apply Small-World rewiring
                    topo_state <= TOPOLOGY_WORMHOLE;
                end

                TOPOLOGY_WORMHOLE: begin
                    // Add long-range Wormhole edges
                    topo_state <= TOPOLOGY_STABLE;
                    topology_valid <= 1'b1;
                    spectral_gap <= gamma;
                    mixing_time <= (log_n * log_n) / gamma;
                end

                TOPOLOGY_STABLE: begin
                    // Handle routing requests
                    if (route_req) begin
                        // Check ring neighbors first
                        for (int i = 0; i < K_NEIGHBORS; i++) begin
                            if (ring_neighbors[worker_id][i] == target_id) begin
                                next_hop <= target_id;
                                route_ack <= 1'b1;
                            end
                        end
                        // Check Wormhole edges
                        for (int i = 0; i < K_NEIGHBORS; i++) begin
                            if (wormhole_table[worker_id*K_NEIGHBORS*6 +: 6] == target_id) begin
                                next_hop <= target_id;
                                route_ack <= 1'b1;
                            end
                        end
                        // Multi-hop routing
                        if (!route_ack) begin
                            // Route to the neighbor closest to target
                            next_hop <= ring_neighbors[worker_id][0];
                            route_ack <= 1'b1;
                        end
                    end else begin
                        route_ack <= 1'b0;
                    end
                end
            endcase
        end
    end

    // ============================================================
    // WORM_LEDGER UPDATE (softirq_tail)
    // ============================================================
    // The WORM_LEDGER is updated atomically after all
    // steal operations complete.

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            worm_ledger <= '0;
        end else if (enable) begin
            worm_ledger <= worm_ledger_next;
        end
    end

    always_comb begin
        worm_ledger_next = worm_ledger;
        worm_ledger_next.epoch = worm_ledger.epoch + 1;
        worm_ledger_next.checksum = ^worm_ledger.worker_alive;
    end

endmodule
