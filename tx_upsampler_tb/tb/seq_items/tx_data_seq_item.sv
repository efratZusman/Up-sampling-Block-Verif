 import uvm_pkg::*;
  `include "uvm_macros.svh"

class tx_data_seq_item extends uvm_sequence_item;
  `uvm_object_utils(tx_data_seq_item)

  rand bit [15:0] i;
  rand bit [15:0] q;
  rand bit        valid;
  rand int        num_clk_dly;

  // limit drive length to a small, reasonable range to avoid extremely long
  // repeated drives that would flood the DUT and produce many outputs.
  constraint dly_c { num_clk_dly inside {[1:4]}; }

  function new(string name="tx_data_seq_item");
    super.new(name);
  endfunction
endclass
