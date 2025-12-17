class tx_config_change_seq extends uvm_sequence #(tx_config_seq_item);
  `uvm_object_utils(tx_config_change_seq)

  function new(string name="tx_config_change_seq");
    super.new(name);
  endfunction

  task body();
    tx_config_seq_item req;

    // first config
    req = tx_config_seq_item::type_id::create("cfg1");
    start_item(req);
    assert(req.randomize());
    finish_item(req);

    // second config (between bursts)
    req = tx_config_seq_item::type_id::create("cfg2");
    start_item(req);
    assert(req.randomize());
    finish_item(req);
  endtask
endclass
