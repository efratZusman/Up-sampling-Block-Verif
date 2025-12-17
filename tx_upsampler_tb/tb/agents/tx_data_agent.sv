class tx_data_agent extends uvm_agent;
  `uvm_component_utils(tx_data_agent)

  tx_data_driver    driver_i;
  tx_data_sequencer sequencer_i;
  tx_data_monitor   monitor_i;

  function new(string name="tx_data_agent", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(get_is_active()) begin
      driver_i    = tx_data_driver::type_id::create("driver_i", this);
      sequencer_i = tx_data_sequencer::type_id::create("sequencer_i", this);
    end

    monitor_i = tx_data_monitor::type_id::create("monitor_i", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(get_is_active()) begin
      driver_i.seq_item_port.connect(sequencer_i.seq_item_export);
    end
  endfunction

endclass
