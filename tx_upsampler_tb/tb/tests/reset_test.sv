class reset_test extends base_test;
  `uvm_component_utils(reset_test)
  function new(string name="reset_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  task run_phase(uvm_phase phase);
    tx_reset_vseq vseq;

    vseq = tx_reset_vseq::type_id::create("vseq");
    vseq.set_env(env_i);

    vseq.starting_phase = phase;
    vseq.start(null);
  endtask

endclass
