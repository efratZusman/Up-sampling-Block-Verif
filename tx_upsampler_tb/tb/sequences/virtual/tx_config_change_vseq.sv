class tx_config_change_vseq extends tx_base_vseq;
  `uvm_object_utils(tx_config_change_vseq)
  
  function new(string name="tx_config_change_vseq");
    super.new(name);
  endfunction

  task body();
    tx_config_seq_item cfg_item1, cfg_item2;
    tx_data_burst_seq  data_seq;
    virtual out_if out_vif;
    
    // Get the output interface from config_db for waiting on completion
    if(!uvm_config_db#(virtual out_if)::get(null, "*", "out_vif", out_vif))
      `uvm_fatal("NO_VIF", "out_vif not found in config_db")
    
    // Step 1: Send initial config (bypass must be OFF)
    `uvm_do_on_with(cfg_item1, env.cfg_agent_i.sequencer_i, {
      bypass == 0;  // MUST be 0 - no bypass during config changes
      factor inside {2'b00, 2'b01, 2'b10, 2'b11};
      mode   inside {1'b0, 1'b1};
    })
    
    // Step 2: Start data and config change in parallel
    data_seq = tx_data_burst_seq::type_id::create("data_seq");
    
    fork
      begin
        // Data stream runs continuously
        data_seq.start(env.data_agent_i.sequencer_i);
      end
      begin
        // Config changes mid-stream:
        // Wait to let some data samples flow through with initial config
        // Enough time for ~2-3 output cycles before changing config
        #80ns;
        
        // Send second config with different values
        `uvm_do_on_with(cfg_item2, env.cfg_agent_i.sequencer_i, {
          bypass == 0;  // MUST remain 0 - still no bypass
          factor != cfg_item1.factor;  // Change factor from first config
          mode   != cfg_item1.mode;    // Change mode from first config
        })
      end
    join
    
    // CRITICAL: Wait for all upsampled outputs to be generated and consumed
    // before test ends. This ensures all data is properly processed.
    wait(out_vif.buffer_level == 5'd0 && out_vif.up_data_valid == 1'b0);
    
    // One more cycle for clean completion
    #10ns;
  endtask
endclass

