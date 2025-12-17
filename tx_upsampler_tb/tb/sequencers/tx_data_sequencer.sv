class tx_data_sequencer extends uvm_sequencer #(tx_data_seq_item);
  `uvm_component_utils(tx_data_sequencer)

  function new(string name="tx_data_sequencer", uvm_component parent=null);
    super.new(name, parent);
  endfunction

endclass
