class base_test extends uvm_test;
  `uvm_component_utils(base_test)

  tx_env env_i;

  function new(string name="base_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    env_i = tx_env::type_id::create("env_i", this);

    // set agents active/passive
    uvm_config_db#(uvm_active_passive_enum)::set(this,
      "env_i.data_agent_i", "is_active", UVM_ACTIVE);
    uvm_config_db#(uvm_active_passive_enum)::set(this,
      "env_i.cfg_agent_i", "is_active", UVM_ACTIVE);
    uvm_config_db#(uvm_active_passive_enum)::set(this,
      "env_i.out_agent_i", "is_active", UVM_PASSIVE);
  endfunction

endclass
