class bypass_change_test extends base_test;
  `uvm_component_utils(bypass_change_test)
  
      function new(string name="bypass_change_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction


  task run_phase(uvm_phase phase);
    tx_bypass_change_vseq vseq;

    vseq = tx_bypass_change_vseq::type_id::create("vseq");
    vseq.set_env(env_i);

    vseq.starting_phase = phase;
    vseq.start(null);
  endtask

endclass
