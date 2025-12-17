class tx_data_idle_seq extends uvm_sequence #(tx_data_seq_item);
  `uvm_object_utils(tx_data_idle_seq)

  function new(string name="tx_data_idle_seq");
    super.new(name);
  endfunction

  task body();
    tx_data_seq_item req;
    repeat(5) begin
      req = tx_data_seq_item::type_id::create("req");
      start_item(req);
      req.valid = 0;
      finish_item(req);
    end
  endtask
endclass
