 import uvm_pkg::*;
  `include "uvm_macros.svh"

class tx_config_seq_item extends uvm_sequence_item;
  `uvm_object_utils(tx_config_seq_item)

  rand bit [1:0] factor;
  rand bit       bypass;
  rand bit       mode;

  function new(string name="tx_config_seq_item");
    super.new(name);
  endfunction
endclass
