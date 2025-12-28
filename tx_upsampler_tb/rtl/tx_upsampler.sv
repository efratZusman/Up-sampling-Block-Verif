module tx_upsampler (
    input              clk,
    input              rst_n,

    // Input interface
    input      [15:0]  tx_data_i,
    input      [15:0]  tx_data_q,
    input              tx_data_valid,
    input      [1:0]   upsampling_factor,   // 00=2, 01=4, 10=8, 11=16
    input              bypass_enable,       // 1 => 1:1 ratio (bypass upsampling)
    input              upsample_mode,       // 0=zero insertion, 1=sample-and-hold

    // Output interface
    output reg [15:0]  up_data_i,
    output reg [15:0]  up_data_q,
    output reg         up_data_valid,
        output reg [7:0]   sample_count,        // diagnostic
        output reg [4:0]   buffer_level         // FIFO fill level (0..16)
);

    localparam ZERO_INSERT = 1'b0;
    localparam SAMPLE_HOLD = 1'b1;

    // -------------------------
    // FIFO storage (16 samples)
    // -------------------------
    reg [15:0] buf_i [0:15];
    reg [15:0] buf_q [0:15];
    reg [3:0]  wr_ptr, rd_ptr;

    // -------------------------
    // Stream-latched configuration
    // -------------------------
    reg        in_stream;
    reg        bypass_latched;
    reg [1:0]  factor_latched;
    reg        mode_latched;

    // -------------------------
    // Upsampling state
    // rep_idx: 0..factor-1 for current held sample
    // -------------------------
    reg [15:0] hold_i, hold_q;
    reg [4:0]  rep_idx;        // enough for up to 16
    reg [4:0]  factor_val;     // 2/4/8/16

    // Decode factor from latched factor
    always @(*) begin
        case (factor_latched)
            2'b00: factor_val = 5'd2;
            2'b01: factor_val = 5'd4;
            2'b10: factor_val = 5'd8;
            default: factor_val = 5'd16;
        endcase
    end

    // Idle definition (used to detect end-of-stream)
    wire idle_now = (buffer_level == 5'd0) && (rep_idx == 5'd0);

    // Stream start: first valid when not already in stream
    wire stream_start = (!in_stream) && tx_data_valid;
    // Consider stream active on first-valid cycle or while in_stream
    wire stream_active = in_stream || stream_start;

    // Stream end: require FIFO empty, no repetition active, no new input
    // and no outstanding output valid — be strict so in_stream clears only
    // after the last output slot has been produced.
    wire stream_end = in_stream && (buffer_level == 5'd0) && (rep_idx == 5'd0) && (!tx_data_valid) && (!up_data_valid);

        // FIFO control (computed in sequential block)
        wire fifo_full  = (buffer_level == 5'd16);
        wire fifo_empty = (buffer_level == 5'd0);

    // Use current bypass configuration on first cycle, latched thereafter
    wire bypass_cfg = in_stream ? bypass_latched : bypass_enable;

    // Write allowed only in upsampling mode (not bypass) and during active stream
    // including the very first valid cycle
    wire do_write = stream_active && (!bypass_cfg) && tx_data_valid && (!fifo_full);

    // Read when we need a new held sample (rep_idx==0) and FIFO has data
    wire need_new = (!bypass_cfg) && (rep_idx == 5'd0) && (!fifo_empty);

    // Output valid in upsampling mode when we have an active repetition window
    wire up_active = (!bypass_cfg) && (rep_idx != 5'd0);

    // -------------------------
    // Main sequential
    // -------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Spec reset behavior: initialize all states, sample counter resets,
            // control to default state (1:2, zero insertion). :contentReference[oaicite:2]{index=2}
            wr_ptr         <= 4'd0;
            rd_ptr         <= 4'd0;
            buffer_level   <= 5'd0;

            hold_i         <= 16'd0;
            hold_q         <= 16'd0;
            rep_idx        <= 5'd0;

            in_stream      <= 1'b0;
            bypass_latched <= 1'b0;
            factor_latched <= 2'b00; // default 1:2 :contentReference[oaicite:3]{index=3}
            mode_latched   <= ZERO_INSERT; // default zero insertion :contentReference[oaicite:4]{index=4}

            up_data_i      <= 16'd0;
            up_data_q      <= 16'd0;
            up_data_valid  <= 1'b0;

            sample_count   <= 8'd0;

`ifdef DEBUG
            $display("Reset: in_stream = %b, up_data_valid = %b", in_stream, up_data_valid);
`endif
        end else begin
            // -------------------------
            // Stream tracking + latch config at stream start only
            // -------------------------
            if (stream_start) begin
                in_stream      <= 1'b1;
                bypass_latched <= bypass_enable;
                factor_latched <= upsampling_factor;
                mode_latched   <= upsample_mode;
`ifdef DEBUG
                $display("Stream started: in_stream = %b, tx_data_valid = %b", in_stream, tx_data_valid);
`endif
            end else if (stream_end) begin
                in_stream <= 1'b0;
`ifdef DEBUG
                $display("Stream ended: in_stream = %b", in_stream);
`endif
            end

            // -------------------------
            // BYPASS (1:1) – use current/latched bypass (covers first cycle too)
            // -------------------------
            if (stream_active && bypass_cfg) begin
                up_data_valid <= tx_data_valid;
                up_data_i     <= tx_data_i;
                up_data_q     <= tx_data_q;

                // In bypass, FIFO/upsampler are not used; keep them cleared/idle.
                wr_ptr       <= 4'd0;
                rd_ptr       <= 4'd0;
                buffer_level <= 5'd0;
                rep_idx      <= 5'd0;

                if (tx_data_valid)
                    sample_count <= sample_count + 8'd1;

`ifdef DEBUG
                $display("Bypass mode: up_data_valid = %b, sample_count = %d", up_data_valid, sample_count);
`endif
            end

            // -------------------------
            // UPSAMPLING MODE
            // -------------------------
            else begin
                // 1) FIFO write
                if (do_write) begin
                    buf_i[wr_ptr] <= tx_data_i;
                    buf_q[wr_ptr] <= tx_data_q;
                    wr_ptr        <= wr_ptr + 4'd1;
`ifdef DEBUG
                    $display("FIFO write: wr_ptr = %d, buffer_level = %d", wr_ptr, buffer_level);
`endif
                end

                // 2) FIFO read & start repetition window if needed
                if (need_new) begin
                    hold_i <= buf_i[rd_ptr];
                    hold_q <= buf_q[rd_ptr];
                    rd_ptr <= rd_ptr + 4'd1;
                    rep_idx <= 5'd1;
`ifdef DEBUG
                    $display("FIFO read: rep_idx = %d, rd_ptr = %d", rep_idx, rd_ptr);
`endif
                end

                // 3) Produce output if active (rep_idx != 0)
                if ((!bypass_latched) && (rep_idx != 5'd0)) begin
                    up_data_valid <= 1'b1;

                    // slot_index = rep_idx - 1 (0..factor-1)
                    if (mode_latched == ZERO_INSERT) begin
                        if (rep_idx == 5'd1) begin
                            up_data_i <= hold_i;
                            up_data_q <= hold_q;
                        end else begin
                            up_data_i <= 16'd0;
                            up_data_q <= 16'd0;
                        end
                    end else begin
                        up_data_i <= hold_i;
                        up_data_q <= hold_q;
                    end

                    sample_count <= sample_count + 8'd1;
`ifdef DEBUG
                    $display("Producing data: up_data_valid = %b, up_data_i = %d, up_data_q = %d, sample_count = %d", up_data_valid, up_data_i, up_data_q, sample_count);
`endif

                    // advance repetition window
                    if (rep_idx == factor_val) begin
                        rep_idx <= 5'd0;
                    end else begin
                        rep_idx <= rep_idx + 5'd1;
                    end
                end else begin
                    // EXPLICIT: When rep_idx==0 or bypass, stop output
                    up_data_valid <= 1'b0;
                end

                // 4) Update buffer_level deterministically (write - read)
                begin : level_update
                    integer tmp;
                    tmp = buffer_level;
                    if (do_write)
                        tmp = tmp + 1;
                    if (need_new)
                        tmp = tmp - 1;
                    if (tmp < 0)
                        tmp = 0;
                    else if (tmp > 16)
                        tmp = 16;
                    buffer_level <= tmp;
`ifdef DEBUG
                    $display("Buffer level updated: old=%0d write=%b read=%b new=%0d", buffer_level, do_write, need_new, tmp);
`endif
                end
            end
        end
    end
endmodule
