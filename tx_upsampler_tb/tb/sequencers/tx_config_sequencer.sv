class tx_config_sequencer extends uvm_sequencer #(tx_config_seq_item);
  `uvm_component_utils(tx_config_sequencer)

  function new(string name="tx_config_sequencer", uvm_component parent=null);
    super.new(name, parent);
  endfunction

endclass
