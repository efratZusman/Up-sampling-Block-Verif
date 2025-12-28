class tx_reset_vseq extends tx_base_vseq;
  `uvm_object_utils(tx_reset_vseq)
  
  function new(string name="tx_reset_vseq");
    super.new(name);
  endfunction

  task body();
    env.data_agent_i.driver_i.data_vif.rst_n <= 0;
    repeat(5) @(posedge env.data_agent_i.driver_i.data_vif.clk);
    env.data_agent_i.driver_i.data_vif.rst_n <= 1;
  endtask
endclass
