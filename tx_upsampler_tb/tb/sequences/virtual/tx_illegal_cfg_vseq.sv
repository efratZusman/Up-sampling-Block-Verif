class tx_illegal_cfg_vseq extends tx_base_vseq;
  `uvm_object_utils(tx_illegal_cfg_vseq)

  task body();
    tx_config_illegal_seq cfg_seq;
    cfg_seq = tx_config_illegal_seq::type_id::create("cfg_seq");
    cfg_seq.start(env.cfg_agent_i.sequencer_i);
  endtask
endclass
