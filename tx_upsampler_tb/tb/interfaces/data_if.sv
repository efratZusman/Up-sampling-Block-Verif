interface data_if(input logic clk);
  logic rst_n;
  logic [15:0] tx_data_i;
  logic [15:0] tx_data_q;
  logic        tx_data_valid;
endinterface
