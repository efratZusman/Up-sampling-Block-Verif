//====================================================
// TX Upsampler – Spec-aligned RTL (FIFO=16) + Stream-latched config
// Modes: Zero-Insertion, Sample-and-Hold, Bypass (1:1)
// Bypass/factor/mode are latched ONLY at stream start.
//====================================================

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
    output reg [3:0]   buffer_level         // FIFO fill level
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
    wire idle_now = (buffer_level == 4'd0) && (rep_idx == 5'd0);

    // Stream start: first valid when not already in stream
    wire stream_start = (!in_stream) && tx_data_valid;

    // Stream end: idle and no input valid
    wire stream_end = in_stream && idle_now && (!tx_data_valid);

    // FIFO control (computed in sequential block)
    wire fifo_full  = (buffer_level == 4'd16);
    wire fifo_empty = (buffer_level == 4'd0);

    // Write allowed only in upsampling mode (not bypass) and during a stream
    wire do_write = in_stream && (!bypass_latched) && tx_data_valid && (!fifo_full);

    // Read when we need a new held sample (rep_idx==0) and FIFO has data
    wire need_new = (!bypass_latched) && (rep_idx == 5'd0) && (!fifo_empty);

    // Output valid in upsampling mode when we have an active repetition window
    wire up_active = (!bypass_latched) && (rep_idx != 5'd0);

    // -------------------------
    // Main sequential
    // -------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Spec reset behavior: initialize all states, sample counter resets,
            // control to default state (1:2, zero insertion). :contentReference[oaicite:2]{index=2}
            wr_ptr         <= 4'd0;
            rd_ptr         <= 4'd0;
            buffer_level   <= 4'd0;

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
        end else begin
            // -------------------------
            // Stream tracking + latch config at stream start only
            // -------------------------
            if (stream_start) begin
                in_stream      <= 1'b1;
                bypass_latched <= bypass_enable;
                factor_latched <= upsampling_factor;
                mode_latched   <= upsample_mode;
            end else if (stream_end) begin
                in_stream <= 1'b0;
                // leave latched values as-is until next stream_start
            end

            // -------------------------
            // BYPASS (1:1) – only uses latched bypass
            // -------------------------
            if (in_stream && bypass_latched) begin
                up_data_valid <= tx_data_valid;
                up_data_i     <= tx_data_i;
                up_data_q     <= tx_data_q;

                // In bypass, FIFO/upsampler are not used; keep them cleared/idle.
                wr_ptr       <= 4'd0;
                rd_ptr       <= 4'd0;
                buffer_level <= 4'd0;
                rep_idx      <= 5'd0;

                if (tx_data_valid)
                    sample_count <= sample_count + 8'd1;
            end

            // -------------------------
            // UPSAMPLING MODE
            // -------------------------
            else begin
                // Default output when not producing samples
                up_data_valid <= 1'b0;

                // 1) FIFO write
                if (do_write) begin
                    buf_i[wr_ptr] <= tx_data_i;
                    buf_q[wr_ptr] <= tx_data_q;
                    wr_ptr        <= wr_ptr + 4'd1;
                end

                // 2) FIFO read & start repetition window if needed
                if (in_stream && need_new) begin
                    hold_i <= buf_i[rd_ptr];
                    hold_q <= buf_q[rd_ptr];
                    rd_ptr <= rd_ptr + 4'd1;

                    // Start repetitions: rep_idx=1 means "we are producing now"
                    // with (rep_idx-1) representing the slot index 0..factor-1.
                    rep_idx <= 5'd1;
                end

                // 3) Produce output if active (rep_idx != 0)
                if (in_stream && (!bypass_latched) && (rep_idx != 5'd0)) begin
                    up_data_valid <= 1'b1;

                    // slot_index = rep_idx - 1 (0..factor-1)
                    if (mode_latched == ZERO_INSERT) begin
                        // Zero insertion: output sample at slot 0, zeros otherwise. :contentReference[oaicite:5]{index=5}
                        if (rep_idx == 5'd1) begin
                            up_data_i <= hold_i;
                            up_data_q <= hold_q;
                        end else begin
                            up_data_i <= 16'd0;
                            up_data_q <= 16'd0;
                        end
                    end else begin
                        // Sample-and-hold: repeat the sample factor times. :contentReference[oaicite:6]{index=6}
                        up_data_i <= hold_i;
                        up_data_q <= hold_q;
                    end

                    sample_count <= sample_count + 8'd1;

                    // advance repetition window
                    if (rep_idx == factor_val) begin
                        rep_idx <= 5'd0;        // done with this sample
                    end else begin
                        rep_idx <= rep_idx + 5'd1;
                    end
                end

                // 4) Update buffer_level ONCE (single driver), accounting for read/write same cycle
                begin : level_update
                    reg write_inc;
                    reg read_dec;
                    write_inc = do_write ? 1'b1 : 1'b0;
                    read_dec  = (in_stream && need_new) ? 1'b1 : 1'b0;

                    case ({write_inc, read_dec})
                        2'b10: buffer_level <= buffer_level + 4'd1; // write only
                        2'b01: buffer_level <= buffer_level - 4'd1; // read only
                        default: buffer_level <= buffer_level;      // none or both
                    endcase
                end
            end
        end
    end

endmodule