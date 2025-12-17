class tx_out_agent extends uvm_agent;
  `uvm_component_utils(tx_out_agent)

  tx_out_monitor monitor_i;

  function new(string name="tx_out_agent", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    monitor_i = tx_out_monitor::type_id::create("monitor_i", this);
  endfunction

endclass
