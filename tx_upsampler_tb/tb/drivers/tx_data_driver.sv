class tx_env extends uvm_env;
  `uvm_component_utils(tx_env)

  tx_data_agent   data_agent_i;
  tx_config_agent cfg_agent_i;
  tx_out_agent    out_agent_i;

  tx_scoreboard scoreboard_i;
  tx_coverage   coverage_i;

  function new(string name="tx_env", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    data_agent_i   = tx_data_agent::type_id::create("data_agent_i", this);
    cfg_agent_i    = tx_config_agent::type_id::create("cfg_agent_i", this);
    out_agent_i    = tx_out_agent::type_id::create("out_agent_i", this);

    scoreboard_i   = tx_scoreboard::type_id::create("scoreboard_i", this);
    coverage_i     = tx_coverage::type_id::create("coverage_i", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // connect monitor ports to scoreboard
    data_agent_i.monitor_i.data_in_port.connect(scoreboard_i.data_in_imp);
    cfg_agent_i.monitor_i.cfg_port.connect(scoreboard_i.cfg_imp);
    out_agent_i.monitor_i.out_port.connect(scoreboard_i.out_imp);
  endfunction

endclass
