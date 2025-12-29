class reset_test extends base_test;
  `uvm_component_utils(reset_test)
  function new(string name="reset_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  task run_phase(uvm_phase phase);
    tx_reset_vseq vseq;
    tx_config_basic_seq cfg_seq;
    tx_data_basic_seq   data_seq;

    phase.raise_objection(this);

    // Create sequences
    cfg_seq  = tx_config_basic_seq::type_id::create("cfg_seq");
    data_seq = tx_data_basic_seq::type_id::create("data_seq");
    vseq     = tx_reset_vseq::type_id::create("vseq");
    vseq.set_env(env_i);

    // Start config and data sequences in parallel with reset sequence
    fork
      cfg_seq.start(env_i.cfg_agent_i.sequencer_i);
      data_seq.start(env_i.data_agent_i.sequencer_i);
      vseq.start(null);
    join

    phase.drop_objection(this);
  endtask

endclass
