class illegal_config_test extends base_test;
  `uvm_component_utils(illegal_config_test)

      function new(string name="illegal_config_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  task run_phase(uvm_phase phase);
    tx_illegal_cfg_vseq vseq;

    vseq = tx_illegal_cfg_vseq::type_id::create("vseq");
    vseq.set_env(env_i);

    vseq.starting_phase = phase;
    vseq.start(null);
  endtask

endclass
