class tx_data_burst_seq extends uvm_sequence #(tx_data_seq_item);
  `uvm_object_utils(tx_data_burst_seq)

  function new(string name="tx_data_burst_seq");
    super.new(name);
  endfunction

  task body();
    tx_data_seq_item req;

    // burst
    repeat(8) begin
      req = tx_data_seq_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with { valid == 1; });
      finish_item(req);
    end

    // end-of-stream (idle)
    req = tx_data_seq_item::type_id::create("idle");
    start_item(req);
    req.valid = 0;
    finish_item(req);
  endtask
endclass
