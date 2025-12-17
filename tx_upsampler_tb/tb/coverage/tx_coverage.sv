class tx_coverage extends uvm_component;
  `uvm_component_utils(tx_coverage)

  virtual config_if cfg_vif;

  covergroup cfg_cg @(posedge cfg_vif.clk);
    factor_cp : coverpoint cfg_vif.upsampling_factor
    {
      bins x2  = {2'b00};
      bins x4  = {2'b01};
      bins x8  = {2'b10};
      bins x16 = {2'b11};
    }

    mode_cp : coverpoint cfg_vif.upsample_mode
    {
      bins zero_insert = {0};
      bins sample_hold = {1};
    }

    bypass_cp : coverpoint cfg_vif.bypass_enable
    {
      bins off = {0};
      bins on  = {1};
    }

    cfg_cross : cross factor_cp, mode_cp, bypass_cp;
  endgroup

  function new(string name="tx_coverage", uvm_component parent=null);
    super.new(name,parent);
    cfg_cg = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual config_if)::get(this,"","cfg_vif",cfg_vif))
      `uvm_fatal("NO_VIF","config_if not set for coverage")
  endfunction

endclass
