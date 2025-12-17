class tx_config_driver extends uvm_driver #(tx_config_seq_item);
  `uvm_component_utils(tx_config_driver)

  virtual config_if cfg_vif;

  function new(string name="tx_config_driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual config_if)::get(this,"","cfg_vif",cfg_vif))
      `uvm_fatal("NO_VIF","config_if not set for config driver")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      drive_cfg(req);
      seq_item_port.item_done();
      @(posedge cfg_vif.clk);
    end
  endtask

  task drive_cfg(tx_config_seq_item req);
    cfg_vif.upsampling_factor <= req.factor;
    cfg_vif.bypass_enable     <= req.bypass;
    cfg_vif.upsample_mode     <= req.mode;
  endtask

endclass
