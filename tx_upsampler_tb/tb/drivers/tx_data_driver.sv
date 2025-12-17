class tx_data_driver extends uvm_driver #(tx_data_seq_item);
  `uvm_component_utils(tx_data_driver)

  virtual data_if data_vif;

  function new(string name="tx_data_driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual data_if)::get(this,"","data_vif",data_vif))
      `uvm_fatal("NO_VIF","data_if not set for data driver")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      wait(data_vif.rst_n == 1);
      seq_item_port.get_next_item(req);
      drive_item(req);
      seq_item_port.item_done();
    end
  endtask

  task drive_item(tx_data_seq_item req);
    data_vif.tx_data_valid <= req.valid;
    data_vif.tx_data_i     <= req.i;
    data_vif.tx_data_q     <= req.q;
    repeat(req.num_clk_dly) @(posedge data_vif.clk);
  endtask

endclass
