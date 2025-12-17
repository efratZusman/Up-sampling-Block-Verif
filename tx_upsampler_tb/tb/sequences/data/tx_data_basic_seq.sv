class tx_data_basic_seq extends uvm_sequence #(tx_data_seq_item);
  `uvm_object_utils(tx_data_basic_seq)

  function new(string name="tx_data_basic_seq");
    super.new(name);
  endfunction

  task pre_body();
    if(starting_phase != null)
      starting_phase.raise_objection(this);
  endtask

  task body();
    tx_data_seq_item req;
    repeat(10) begin
      req = tx_data_seq_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with { valid == 1; });
      finish_item(req);
    end
  endtask

  task post_body();
    if(starting_phase != null)
      starting_phase.drop_objection(this);
  endtask
endclass
