class tx_bypass_vseq extends tx_base_vseq;
  `uvm_object_utils(tx_bypass_vseq)
  
    function new(string name="tx_bypass_vseq");
    super.new(name);
  endfunction

  task body();
    tx_config_basic_seq cfg_seq;
    tx_data_basic_seq   data_seq;

    cfg_seq = tx_config_basic_seq::type_id::create("cfg_seq");
    cfg_seq.start(env.cfg_agent_i.sequencer_i);

    data_seq = tx_data_basic_seq::type_id::create("data_seq");
    data_seq.start(env.data_agent_i.sequencer_i);
  endtask
endclass
