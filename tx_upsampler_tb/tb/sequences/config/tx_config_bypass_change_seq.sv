class tx_config_bypass_change_seq extends uvm_sequence #(tx_config_seq_item);
  `uvm_object_utils(tx_config_bypass_change_seq)

  function new(string name="tx_config_bypass_change_seq");
    super.new(name);
  endfunction

  task pre_body();
    if(starting_phase != null)
      starting_phase.raise_objection(this);
  endtask

  task body();
    tx_config_seq_item req;
    
    // Initial config: bypass OFF, with specific factor and mode
    req = tx_config_seq_item::type_id::create("req_initial");
    start_item(req);
    req.factor = 2'b01;  // x4 upsampling
    req.bypass = 1'b0;   // bypass OFF - normal upsampling
    req.mode   = 1'b0;   // zero insertion mode
    finish_item(req);

    // Wait a few cycles (5 * 10ns clock = 50ns) to let upsampling operate
    #50ns;

    // Change bypass to ON - factor and mode stay the same
    req = tx_config_seq_item::type_id::create("req_bypass_on");
    start_item(req);
    req.factor = 2'b01;  // SAME - x4 upsampling
    req.bypass = 1'b1;   // bypass ON - 1:1 passthrough
    req.mode   = 1'b0;   // SAME - zero insertion mode
    finish_item(req);

    // Wait longer in bypass mode to observe effect clearly (10 * 10ns = 100ns)
    #100ns;

    // Change bypass back to OFF - should resume upsampling
    req = tx_config_seq_item::type_id::create("req_bypass_off");
    start_item(req);
    req.factor = 2'b01;  // SAME - x4 upsampling
    req.bypass = 1'b0;   // bypass OFF - back to normal upsampling
    req.mode   = 1'b0;   // SAME - zero insertion mode
    finish_item(req);

    // Wait to see it resumes upsampling behavior (5 * 10ns = 50ns)
    #50ns;

  endtask

  task post_body();
    if(starting_phase != null)
      starting_phase.drop_objection(this);
  endtask
endclass
