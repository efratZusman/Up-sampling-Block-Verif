class illegal_config_test extends base_test;
  `uvm_component_utils(illegal_config_test)

  task run_phase(uvm_phase phase);
    tx_illegal_cfg_vseq vseq;

    vseq = tx_illegal_cfg_vseq::type_id::create("vseq");
    vseq.set_env(env_i);

    vseq.starting_phase = phase;
    vseq.start(null);
  endtask

endclass
