// must be visible before class declaration
`uvm_analysis_imp_decl(_data_in)
`uvm_analysis_imp_decl(_cfg)
`uvm_analysis_imp_decl(_out)

class tx_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(tx_scoreboard)

  // typed analysis imps with unique callback names
  uvm_analysis_imp_data_in #(tx_data_seq_item,   tx_scoreboard) data_in_imp;
  uvm_analysis_imp_cfg     #(tx_config_seq_item, tx_scoreboard) cfg_imp;
  uvm_analysis_imp_out     #(tx_data_seq_item,   tx_scoreboard) out_imp;

  bit [1:0] factor_latched;
  bit       bypass_latched;
  bit       mode_latched;

  int rep_count;
  tx_data_seq_item last_data;

  function new(string name="tx_scoreboard", uvm_component parent=null);
    super.new(name,parent);
    data_in_imp = new("data_in_imp", this);
    cfg_imp     = new("cfg_imp", this);
    out_imp     = new("out_imp", this);
  endfunction

  // callback for cfg_imp
  function void write_cfg(tx_config_seq_item cfg);
    factor_latched = cfg.factor;
    bypass_latched = cfg.bypass;
    mode_latched   = cfg.mode;
    rep_count      = 0;
//     `uvm_info("SB","Config latched",UVM_LOW)
  endfunction

  // callback for data_in_imp
  function void write_data_in(tx_data_seq_item data);
    last_data = data;
    if (bypass_latched)
      rep_count = 1;
    else
      rep_count = (1 << (factor_latched + 1));
  endfunction

  // callback for out_imp
  function void write_out(tx_data_seq_item out);
    if (bypass_latched) begin
      if (out.i !== last_data.i || out.q !== last_data.q)
        `uvm_error("SB","Bypass output mismatch")
    end
    else begin
      if (mode_latched == 0) begin
        // zero insertion: only first slot is data, others must be zero
        if (rep_count > 1) begin
          if (out.i != 0 || out.q != 0)
            `uvm_error("SB","Zero insertion violation")
        end
      end
      else begin
        // sample-and-hold: always repeat last sample
        if (out.i !== last_data.i || out.q !== last_data.q)
          `uvm_error("SB","Sample & hold mismatch")
      end
    end
  endfunction

endclass
