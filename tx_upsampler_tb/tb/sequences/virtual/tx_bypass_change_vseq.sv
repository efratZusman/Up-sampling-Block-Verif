class tx_bypass_change_vseq extends tx_base_vseq;
  `uvm_object_utils(tx_bypass_change_vseq)

  task body();
    tx_config_illegal_seq cfg_seq;
    tx_data_burst_seq     data_seq;

    data_seq = tx_data_burst_seq::type_id::create("data_seq");
    fork
      data_seq.start(env.data_agent_i.sequencer_i);
      begin
        #20;
        cfg_seq = tx_config_illegal_seq::type_id::create("cfg_seq");
        cfg_seq.start(env.cfg_agent_i.sequencer_i);
      end
    join
  endtask
endclass
