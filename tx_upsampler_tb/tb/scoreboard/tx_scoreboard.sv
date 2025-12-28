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
  int rep_total;
  int rep_remain;

  function new(string name="tx_scoreboard", uvm_component parent=null);
    super.new(name,parent);
    data_in_imp = new("data_in_imp", this);
    cfg_imp     = new("cfg_imp", this);
    out_imp     = new("out_imp", this);
  endfunction

  // Single generic write handler for all analysis imports.
  function void write(uvm_object item);
    tx_config_seq_item cfg;
    tx_data_seq_item   data;

    // CONFIG
    if($cast(cfg, item)) begin
      factor_latched = cfg.factor;
      bypass_latched = cfg.bypass;
      mode_latched   = cfg.mode;
      rep_count      = 0;

      `uvm_info(get_type_name(),
        $sformatf("Config latched: factor=%0d bypass=%0d mode=%0d",
                   factor_latched,bypass_latched,mode_latched),
        UVM_NONE)
      return;
    end

    // DATA IN
    if($cast(data, item)) begin
      last_data = data;
      if(bypass_latched) begin
        rep_count = 1;
        rep_total = 1;
        rep_remain = 1;
      end else begin
        rep_count = (1 << (factor_latched + 1));
        rep_total = rep_count;
        rep_remain = rep_count;
      end
      return;
    end

    // OUTPUT (tx_data_seq_item)
    if($cast(data, item)) begin
      // This branch is redundant due to previous cast, keep for clarity.
    end

    // In case an output arrives (tx_data_seq_item)
    if($cast(data, item)) begin
      if(bypass_latched) begin
        if(data.i !== last_data.i || data.q !== last_data.q)
          `uvm_error("SB","Bypass output mismatch")
        if(rep_remain > 0) rep_remain = rep_remain - 1;
        return;
      end

      if(rep_remain <= 0) begin
        `uvm_error("SB","Unexpected output: no remaining repetitions")
        return;
      end

      if(mode_latched == 0) begin
        // ZERO INSERTION
        if(rep_remain == rep_total) begin
          if(data.i !== last_data.i || data.q !== last_data.q)
            `uvm_error("SB","Zero insertion first-slot mismatch")
        end else begin
          if(data.i !== 0 || data.q !== 0)
            `uvm_error("SB","Zero insertion violation: expected zero")
        end
      end else begin
        // SAMPLE & HOLD
        if(data.i !== last_data.i || data.q !== last_data.q)
          `uvm_error("SB","Sample & hold mismatch")
      end

      rep_remain = rep_remain - 1;
      return;
    end
  endfunction

endclass
