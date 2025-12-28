class tx_config_change_vseq extends tx_base_vseq;
  `uvm_object_utils(tx_config_change_vseq)
  
      function new(string name="tx_config_change_vseq");
    super.new(name);
  endfunction

  task body();
    tx_config_change_seq cfg_seq;
    tx_data_burst_seq    data_seq;

    cfg_seq  = tx_config_change_seq::type_id::create("cfg_seq");
    data_seq = tx_data_burst_seq::type_id::create("data_seq");

    cfg_seq.start(env.cfg_agent_i.sequencer_i);
    data_seq.start(env.data_agent_i.sequencer_i);
  endtask
endclass
