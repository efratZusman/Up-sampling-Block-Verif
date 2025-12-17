class tx_config_monitor extends uvm_monitor;
  `uvm_component_utils(tx_config_monitor)

  virtual config_if cfg_vif;

  tx_config_seq_item cfg_item;

  uvm_analysis_port #(tx_config_seq_item) cfg_port;

  function new(string name="tx_config_monitor", uvm_component parent=null);
    super.new(name,parent);
    cfg_port = new("cfg_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual config_if)::get(this,"","cfg_vif",cfg_vif))
      `uvm_fatal("NO_VIF","config_if not set for config monitor")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      @(posedge cfg_vif.clk);
      collect_cfg();
    end
  endtask

  task collect_cfg();
    cfg_item = tx_config_seq_item::type_id::create("cfg_item", this);
    cfg_item.factor = cfg_vif.upsampling_factor;
    cfg_item.bypass = cfg_vif.bypass_enable;
    cfg_item.mode   = cfg_vif.upsample_mode;

    `uvm_info(get_type_name(),"CONFIG collected",UVM_NONE)
    cfg_port.write(cfg_item);
  endtask

endclass
