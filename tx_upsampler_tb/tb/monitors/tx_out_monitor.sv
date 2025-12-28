class tx_out_monitor extends uvm_monitor;
  `uvm_component_utils(tx_out_monitor)

  virtual out_if out_vif;

  tx_data_seq_item out_item;

  uvm_analysis_port #(tx_data_seq_item) out_port;

  function new(string name="tx_out_monitor", uvm_component parent=null);
    super.new(name,parent);
    out_port = new("out_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual out_if)::get(this,"","out_vif",out_vif))
      `uvm_fatal("NO_VIF","out_if not set for out monitor")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      @(posedge out_vif.clk);
      if(out_vif.up_data_valid) begin
        collect_out();
      end
    end
  endtask

  task collect_out();
    out_item = tx_data_seq_item::type_id::create("out_item", this);
    out_item.i = out_vif.up_data_i;
    out_item.q = out_vif.up_data_q;

//     `uvm_info(get_type_name(),"OUTPUT collected",UVM_NONE)
    out_port.write(out_item);
  endtask

endclass
