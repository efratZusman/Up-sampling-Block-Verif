class tx_config_illegal_seq extends uvm_sequence #(tx_config_seq_item);
  `uvm_object_utils(tx_config_illegal_seq)

  function new(string name="tx_config_illegal_seq");
    super.new(name);
  endfunction

  task body();
    tx_config_seq_item req;
    req = tx_config_seq_item::type_id::create("illegal_cfg");
    start_item(req);
    assert(req.randomize());
    finish_item(req);
    // intended to be driven mid-stream
  endtask
endclass
