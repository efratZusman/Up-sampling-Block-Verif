interface config_if(input logic clk);
  logic rst_n;
  logic [1:0] upsampling_factor;
  logic       bypass_enable;
  logic       upsample_mode;
endinterface
