class tx_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(tx_scoreboard)

  // analysis imports
  uvm_analysis_imp #(tx_data_seq_item,   tx_scoreboard) data_in_imp;
  uvm_analysis_imp #(tx_config_seq_item, tx_scoreboard) cfg_imp;
  uvm_analysis_imp #(tx_data_seq_item,   tx_scoreboard) out_imp;

  // latched config
  bit [1:0] factor_latched;
  bit       bypass_latched;
  bit       mode_latched;

  // internal state
  int rep_count;
  tx_data_seq_item last_data;

  function new(string name="tx_scoreboard", uvm_component parent=null);
    super.new(name,parent);
    data_in_imp = new("data_in_imp", this);
    cfg_imp     = new("cfg_imp", this);
    out_imp     = new("out_imp", this);
  endfunction

  // -----------------------
  // CONFIG MONITOR -> SB
  // -----------------------
  function void write(tx_config_seq_item cfg);
    factor_latched = cfg.factor;
    bypass_latched = cfg.bypass;
    mode_latched   = cfg.mode;
    rep_count      = 0;

    `uvm_info(get_type_name(),
      $sformatf("Config latched: factor=%0d bypass=%0d mode=%0d",
                 factor_latched,bypass_latched,mode_latched),
      UVM_NONE)
  endfunction

  // -----------------------
  // DATA IN MONITOR -> SB
  // -----------------------
  function void write(tx_data_seq_item data);
    last_data = data;
    if(bypass_latched)
      rep_count = 1;
    else
      rep_count = (1 << (factor_latched + 1));
  endfunction

  // -----------------------
  // OUTPUT MONITOR -> SB
  // -----------------------
  function void write(tx_data_seq_item out);
    if(bypass_latched) begin
      if(out.i !== last_data.i || out.q !== last_data.q)
        `uvm_error("SB","Bypass output mismatch")
    end
    else begin
      if(mode_latched == 0) begin
        // ZERO INSERTION
        if(rep_count > 1) begin
          if(out.i != 0 || out.q != 0)
            `uvm_error("SB","Zero insertion violation")
        end
      end
      else begin
        // SAMPLE & HOLD
        if(out.i !== last_data.i || out.q !== last_data.q)
          `uvm_error("SB","Sample & hold mismatch")
      end
    end
  endfunction

endclass
