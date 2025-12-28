class basic_test extends base_test;
  `uvm_component_utils(basic_test)

  function new(string name="basic_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
task run_phase(uvm_phase phase);
  tx_basic_vseq vseq;
  virtual out_if out_vif;

  phase.raise_objection(this);

  vseq = tx_basic_vseq::type_id::create("vseq");
  vseq.set_env(env_i);
  vseq.start(null);

  // Get the output interface from config_db
  if(!uvm_config_db#(virtual out_if)::get(this, "", "out_vif", out_vif))
    `uvm_fatal("NO_VIF", "out_vif not found in config_db")

  // Wait for FIFO to drain AND output to go idle
  wait(out_vif.buffer_level == 5'd0 && out_vif.up_data_valid == 1'b0);
  
  // One more cycle to ensure clean edge
  @(posedge out_vif.clk);

  phase.drop_objection(this);
endtask


endclass
