class tx_bypass_change_vseq extends tx_base_vseq;
  `uvm_object_utils(tx_bypass_change_vseq)

  function new(string name="tx_bypass_change_vseq");
    super.new(name);
  endfunction

  task body();
    tx_config_bypass_change_seq cfg_seq;
    tx_data_basic_seq           data_seq;

    data_seq = tx_data_basic_seq::type_id::create("data_seq");
    cfg_seq = tx_config_bypass_change_seq::type_id::create("cfg_seq");
    
    // Both sequences use starting_phase for objection management
    data_seq.starting_phase = starting_phase;
    cfg_seq.starting_phase = starting_phase;
    
    fork
      data_seq.start(env.data_agent_i.sequencer_i);
      begin
        #20;
        cfg_seq.start(env.cfg_agent_i.sequencer_i);
      end
    join
  endtask
endclass
