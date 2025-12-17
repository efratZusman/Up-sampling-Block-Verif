class tx_base_vseq extends uvm_sequence;
  `uvm_object_utils(tx_base_vseq)

  tx_env env;

  function new(string name="tx_base_vseq");
    super.new(name);
  endfunction

  function void set_env(tx_env env);
    this.env = env;
  endfunction

  task pre_body();
    if(starting_phase != null)
      starting_phase.raise_objection(this);
  endtask

  task post_body();
    if(starting_phase != null)
      starting_phase.drop_objection(this);
  endtask
endclass
