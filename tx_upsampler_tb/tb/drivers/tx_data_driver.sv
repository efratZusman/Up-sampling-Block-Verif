class tx_data_driver extends uvm_driver#(tx_data_seq_item);
  `uvm_component_utils(tx_data_driver)

  virtual data_if data_vif;

  function new(string name="tx_data_driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual data_if)::get(this, "", "data_vif", data_vif))
      `uvm_fatal("NO_VIF", "data_if not set for data driver")
  endfunction

  task run_phase(uvm_phase phase);
    tx_data_seq_item req;

    // stable defaults (use blocking so outputs are stable immediately)
    data_vif.tx_data_i   = 16'd0;
    data_vif.tx_data_q   = 16'd0;
    data_vif.tx_data_valid = 1'b0;

    @(posedge data_vif.clk);

    while (phase.get_state() != UVM_PHASE_DONE) begin
      seq_item_port.get_next_item(req);

      // drive the item for req.num_clk_dly cycles (at least 1)
      repeat(req.num_clk_dly) begin
        data_vif.tx_data_i   = req.i;
        data_vif.tx_data_q   = req.q;
        data_vif.tx_data_valid = req.valid;
        @(posedge data_vif.clk);
      end

      // Immediately deassert signals after item finishes
      data_vif.tx_data_valid = 1'b0;
      data_vif.tx_data_i   = 16'd0;
      data_vif.tx_data_q   = 16'd0;
      @(posedge data_vif.clk);
      
      seq_item_port.item_done();
    end
  endtask

endclass
