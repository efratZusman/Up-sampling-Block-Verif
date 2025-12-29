class tx_config_single_seq extends uvm_sequence #(tx_config_seq_item);
  `uvm_object_utils(tx_config_single_seq)

  function new(string name="tx_config_single_seq");
    super.new(name);
  endfunction

  task body();
    tx_config_seq_item req;
    req = tx_config_seq_item::type_id::create("req");
    start_item(req);
    assert(req.randomize());
    finish_item(req);
  endtask
endclass
