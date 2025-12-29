class tx_data_basic_seq extends uvm_sequence #(tx_data_seq_item);
  `uvm_object_utils(tx_data_basic_seq)

  // Configurable parameters instead of hardcoded values
  int num_input_samples = 15;
  int upsampling_factor = 4;  // Default: 2, 4, 8, or 16
  int buffer_drain_margin = 20;  // Extra cycles for FIFO drain and output latency

  function new(string name="tx_data_basic_seq");
    super.new(name);
  endfunction

  task pre_body();
    if(starting_phase != null)
      starting_phase.raise_objection(this);
  endtask

  task body();
    tx_data_seq_item req;
    int idle_cycles;

    // Generate input samples
    repeat(num_input_samples) begin
      req = tx_data_seq_item::type_id::create("req");
      start_item(req);
      // randomize but force single-cycle (or small) drive length for determinism
      assert(req.randomize() with { valid == 1; });
      // ensure a short drive so we don't flood the DUT with repeated identical samples
      req.num_clk_dly = 1;
      finish_item(req);
    end
    
    // Calculate idle cycles based on parameters
    // Maximum output samples = num_input_samples * upsampling_factor
    // Add margin for FIFO drain and output pipeline latency
    idle_cycles = (num_input_samples * upsampling_factor) + buffer_drain_margin;
    
    // Wait for final sample's upsampling to complete and FIFO to drain
    repeat(idle_cycles) begin
      req = tx_data_seq_item::type_id::create("req");
      start_item(req);
      req.valid = 0;      // idle, no new data
      req.i = 16'd0;      // explicitly clear data values during idle
      req.q = 16'd0;
      req.num_clk_dly = 1;
      finish_item(req);
    end
  endtask

  task post_body();
    if(starting_phase != null)
      starting_phase.drop_objection(this);
  endtask
endclass
