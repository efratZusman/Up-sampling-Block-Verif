import uvm_pkg::*;

`include "data_if.sv"
`include "config_if.sv"
`include "out_if.sv"
`include "tx_pkg.sv"

import tx_pkg::*;   // <<< חובה

module tb_top;

  logic clk;
  logic rst_n;

  // clock
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // reset
  initial begin
    rst_n = 0;
    repeat(5) @(posedge clk);
    rst_n = 1;
  end

  // interfaces
  data_if   data_if_i(clk);
  config_if cfg_if_i(clk);
  out_if    out_if_i(clk);

  assign data_if_i.rst_n = rst_n;

  // DUT
  tx_upsampler dut (
    .clk(clk),
    .rst_n(rst_n),

    .tx_data_i(data_if_i.tx_data_i),
    .tx_data_q(data_if_i.tx_data_q),
    .tx_data_valid(data_if_i.tx_data_valid),

    .upsampling_factor(cfg_if_i.upsampling_factor),
    .bypass_enable(cfg_if_i.bypass_enable),
    .upsample_mode(cfg_if_i.upsample_mode),

    .up_data_i(out_if_i.up_data_i),
    .up_data_q(out_if_i.up_data_q),
    .up_data_valid(out_if_i.up_data_valid),
    .sample_count(out_if_i.sample_count),
    .buffer_level(out_if_i.buffer_level)
  );

  // config DB: set VIFs
  initial begin
    uvm_config_db#(virtual data_if)::set(null, "*", "data_vif", data_if_i);
    uvm_config_db#(virtual config_if)::set(null, "*", "cfg_vif", cfg_if_i);
    uvm_config_db#(virtual out_if)::set(null, "*", "out_vif", out_if_i);

    run_test("basic_test");
  end

initial begin
  $dumpfile("dump.vcd");

  // להתחיל הקלטה מיד
  #10ns;

  // DATA IF
  $dumpvars(0, tb_top.data_if_i.tx_data_i);
  $dumpvars(0, tb_top.data_if_i.tx_data_q);
  $dumpvars(0, tb_top.data_if_i.tx_data_valid);

  // CFG IF
  $dumpvars(0, tb_top.cfg_if_i.upsampling_factor);
  $dumpvars(0, tb_top.cfg_if_i.bypass_enable);
  $dumpvars(0, tb_top.cfg_if_i.upsample_mode);

  // OUT IF
  $dumpvars(0, tb_top.out_if_i.up_data_i);
  $dumpvars(0, tb_top.out_if_i.up_data_q);
  $dumpvars(0, tb_top.out_if_i.up_data_valid);
  $dumpvars(0, tb_top.out_if_i.sample_count);
  $dumpvars(0, tb_top.out_if_i.buffer_level);

  // חלון הקלטה אמיתי
  #5us;
  $dumpoff;
end




initial begin
  #1ms;
  $display("EDA PLAYGROUND TIMEOUT – FORCED FINISH");
  $finish;
end



endmodule
