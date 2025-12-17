class tx_basic_vseq extends tx_base_vseq;
  `uvm_object_utils(tx_basic_vseq)

  task body();
    tx_config_basic_seq cfg_seq;
    tx_data_basic_seq   data_seq;

    cfg_seq  = tx_config_basic_seq::type_id::create("cfg_seq");
    data_seq = tx_data_basic_seq::type_id::create("data_seq");

    cfg_seq.start(env.cfg_agent_i.sequencer_i);
    data_seq.start(env.data_agent_i.sequencer_i);
  endtask
endclass
