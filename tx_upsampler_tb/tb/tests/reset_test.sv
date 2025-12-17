class reset_test extends base_test;
  `uvm_component_utils(reset_test)

  task run_phase(uvm_phase phase);
    tx_reset_vseq vseq;

    vseq = tx_reset_vseq::type_id::create("vseq");
    vseq.set_env(env_i);

    vseq.starting_phase = phase;
    vseq.start(null);
  endtask

endclass
