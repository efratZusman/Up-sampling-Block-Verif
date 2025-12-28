class tx_data_monitor extends uvm_monitor;
  `uvm_component_utils(tx_data_monitor)

  virtual data_if data_vif;

  tx_data_seq_item data_item;

  uvm_analysis_port #(tx_data_seq_item) data_in_port;

  function new(string name="tx_data_monitor", uvm_component parent=null);
    super.new(name,parent);
    data_in_port = new("data_in_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual data_if)::get(this,"","data_vif",data_vif))
      `uvm_fatal("NO_VIF","data_if not set for data monitor")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      @(posedge data_vif.clk);
      if(data_vif.tx_data_valid) begin
        collect_data();
      end
    end
  endtask

  task collect_data();
    data_item = tx_data_seq_item::type_id::create("data_item", this);
    data_item.i     = data_vif.tx_data_i;
    data_item.q     = data_vif.tx_data_q;
    data_item.valid = data_vif.tx_data_valid;

//     `uvm_info(get_type_name(),"DATA input collected",UVM_NONE)
    data_in_port.write(data_item);
  endtask

endclass
