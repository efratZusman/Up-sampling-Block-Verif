import uvm_pkg::*;
`include "uvm_macros.svh"

class tx_bypass_vseq extends tx_base_vseq;
  `uvm_object_utils(tx_bypass_vseq)
  
  function new(string name="tx_bypass_vseq");
    super.new(name);
  endfunction

  task body();
    tx_data_basic_seq   data_seq;
    tx_config_seq_item  cfg_item;

    // Drive a deterministic bypass configuration before data starts
    // Use UVM macro to send a single item on the config sequencer
    `uvm_do_on_with(cfg_item, env.cfg_agent_i.sequencer_i, {
      bypass == 1;
      // factor/mode are ignored in bypass but set to legal values
      factor inside {2'b00, 2'b01, 2'b10, 2'b11};
      mode   inside {1'b0, 1'b1};
    })

    // Then run the data sequence in bypass mode
    data_seq = tx_data_basic_seq::type_id::create("data_seq");
    data_seq.start(env.data_agent_i.sequencer_i);
    
    // Wait one cycle for the last sample to propagate through registered output
    #10ns;
  endtask
endclass
