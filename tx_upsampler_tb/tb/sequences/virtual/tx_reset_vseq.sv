class tx_reset_vseq extends tx_base_vseq;
  `uvm_object_utils(tx_reset_vseq)
  
  function new(string name="tx_reset_vseq");
    super.new(name);
  endfunction

  task body();
    // Start with reset inactive to let test run normally
    env.data_agent_i.driver_i.data_vif.rst_n <= 1;
    repeat(5) @(posedge env.data_agent_i.driver_i.data_vif.clk);
    
    // Activate reset mid-test to verify all signals go to 0
    env.data_agent_i.driver_i.data_vif.rst_n <= 0;
    env.data_agent_i.driver_i.data_vif.tx_data_valid <= 0;
    repeat(5) @(posedge env.data_agent_i.driver_i.data_vif.clk);
    
    // Release reset to continue
    env.data_agent_i.driver_i.data_vif.rst_n <= 1;
    repeat(20) @(posedge env.data_agent_i.driver_i.data_vif.clk);
  endtask
endclass
