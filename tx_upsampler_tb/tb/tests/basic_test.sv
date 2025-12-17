class basic_test extends base_test;
  `uvm_component_utils(basic_test)

  function new(string name="basic_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  task run_phase(uvm_phase phase);
    tx_basic_vseq vseq;

    vseq = tx_basic_vseq::type_id::create("vseq");
    vseq.set_env(env_i);

    vseq.starting_phase = phase;
    vseq.start(null);
  endtask

endclass
