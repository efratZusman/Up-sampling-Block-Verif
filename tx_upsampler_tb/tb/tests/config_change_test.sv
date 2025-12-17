class config_change_test extends base_test;
  `uvm_component_utils(config_change_test)

  task run_phase(uvm_phase phase);
    tx_config_change_vseq vseq;

    vseq = tx_config_change_vseq::type_id::create("vseq");
    vseq.set_env(env_i);

    vseq.starting_phase = phase;
    vseq.start(null);
  endtask

endclass
