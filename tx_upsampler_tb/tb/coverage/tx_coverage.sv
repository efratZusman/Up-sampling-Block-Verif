class tx_coverage extends uvm_component;
  `uvm_component_utils(tx_coverage)

  virtual config_if cfg_vif;
  // simple textual counters (integer for old SV dialect compatibility)
  integer factor_cnt2;
  integer factor_cnt4;
  integer factor_cnt8;
  integer factor_cnt16;
  integer mode_cnt0;
  integer mode_cnt1;
  integer bypass_cnt0;
  integer bypass_cnt1;

  covergroup cfg_cg;
    option.per_instance = 1;

    factor_cp : coverpoint cfg_vif.upsampling_factor {
      bins x2  = {2'b00};
      bins x4  = {2'b01};
      bins x8  = {2'b10};
      bins x16 = {2'b11};
    }

    mode_cp : coverpoint cfg_vif.upsample_mode {
      bins zero_insert = {1'b0};
      bins sample_hold = {1'b1};
    }

    bypass_cp : coverpoint cfg_vif.bypass_enable {
      bins off = {1'b0};
      bins on  = {1'b1};
    }

    cfg_cross : cross factor_cp, mode_cp, bypass_cp;
  endgroup

  function new(string name="tx_coverage", uvm_component parent=null);
    super.new(name,parent);
    cfg_cg = new();     // <<< חייב להיות כאן בלבד
    // init counters
    factor_cnt2  = 0;
    factor_cnt4  = 0;
    factor_cnt8  = 0;
    factor_cnt16 = 0;
    mode_cnt0    = 0;
    mode_cnt1    = 0;
    bypass_cnt0  = 0;
    bypass_cnt1  = 0;
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual config_if)::get(this,"","cfg_vif",cfg_vif))
      `uvm_fatal("NO_VIF","config_if not set for coverage")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      @(posedge cfg_vif.clk);
      cfg_cg.sample();
      // increment simple textual counters so we can print coverage in the log
      case (cfg_vif.upsampling_factor)
        2'b00: factor_cnt2 = factor_cnt2 + 1;
        2'b01: factor_cnt4 = factor_cnt4 + 1;
        2'b10: factor_cnt8 = factor_cnt8 + 1;
        default: factor_cnt16 = factor_cnt16 + 1;
      endcase

      if (cfg_vif.upsample_mode == 1'b0)
        mode_cnt0 = mode_cnt0 + 1;
      else
        mode_cnt1 = mode_cnt1 + 1;

      if (cfg_vif.bypass_enable == 1'b0)
        bypass_cnt0 = bypass_cnt0 + 1;
      else
        bypass_cnt1 = bypass_cnt1 + 1;
    end
  endtask

  // print final textual coverage summary to simulator log
  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    `uvm_info("TX_COV","Coverage counts (samples observed):",UVM_LOW)
    $display("cfg factor counts: x2=%0d x4=%0d x8=%0d x16=%0d", factor_cnt2, factor_cnt4, factor_cnt8, factor_cnt16);
    $display("cfg mode counts: zero_insert=%0d sample_hold=%0d", mode_cnt0, mode_cnt1);
    $display("cfg bypass counts: off=%0d on=%0d", bypass_cnt0, bypass_cnt1);
  endfunction

   // Report phase - display coverage statistics
//     virtual function void report_phase(uvm_phase phase);
//         super.report_phase(phase);
//         `uvm_info(get_type_name(), $sformatf("\n\n========== COVERAGE REPORT =========="), UVM_LOW)
//         `uvm_info(get_type_name(), $sformatf("Overall Coverage: %.2f%%", cg_pattern_detector.get_coverage()), UVM_LOW)
//         `uvm_info(get_type_name(), $sformatf("=====================================\n"), UVM_LOW)
//     endfunction
  // Report phase - detailed coverage statistics
    virtual function void report_phase(uvm_phase phase);
        real cp_mode_cov, cp_match_cov, cp_mask_cov, cp_types_a, cp_types_b, cx_cross;
       
        super.report_phase(phase);
       
        // Extracting individual coverage percentages
        cp_mode_cov = cg_pattern_detector.cp_mode.get_inst_coverage();
        cp_match_cov = cg_pattern_detector.cp_match_result.get_inst_coverage();
        cp_mask_cov = cg_pattern_detector.cp_mask_patterns.get_inst_coverage();
        cp_types_a = cg_pattern_detector.cp_pattern_types_a.get_inst_coverage();
        cp_types_b = cg_pattern_detector.cp_pattern_types_b.get_inst_coverage();
        cx_cross   = cg_pattern_detector.cx_mode_match.get_inst_coverage();

        `uvm_info(get_type_name(), $sformatf("\n" ,
            "==========================================================\n",
            "                DETAILED COVERAGE REPORT                  \n",
            "==========================================================\n",
            $sformatf("Overall Coverage        : %5.2f%%\n", cg_pattern_detector.get_coverage()),
            "----------------------------------------------------------\n",
            $sformatf("CP Mode Select         : %5.2f%%\n", cp_mode_cov),
            $sformatf("CP Match Result        : %5.2f%%\n", cp_match_cov),
            $sformatf("CP Mask Patterns       : %5.2f%%\n", cp_mask_cov),
            $sformatf("CP Data Stream A Types : %5.2f%%\n", cp_types_a),
            $sformatf("CP Data Stream B Types : %5.2f%%\n", cp_types_b),
            $sformatf("CX Mode x Match Cross  : %5.2f%%\n", cx_cross),
            "=========================================================="), UVM_LOW)
           
        // Check for specific bottlenecks
        if (cp_mask_cov < 50.0) begin
             `uvm_warning(get_type_name(), "Low coverage detected in Mask Patterns! Check constraints.")
        end
    endfunction

endclass
