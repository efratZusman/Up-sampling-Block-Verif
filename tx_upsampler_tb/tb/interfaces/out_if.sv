interface out_if(input logic clk);
  logic [15:0] up_data_i;
  logic [15:0] up_data_q;
  logic        up_data_valid;
  logic [7:0]  sample_count;
  logic [3:0]  buffer_level;
endinterface
