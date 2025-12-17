package tx_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // interfaces
  `include "data_if.sv"
  `include "config_if.sv"
  `include "out_if.sv"

  // sequence items
  `include "tx_data_seq_item.sv"
  `include "tx_config_seq_item.sv"

  // sequencers
  `include "tx_data_sequencer.sv"
  `include "tx_config_sequencer.sv"

  // sequences
  `include "tx_data_basic_seq.sv"
  `include "tx_data_burst_seq.sv"
  `include "tx_data_idle_seq.sv"

  `include "tx_config_basic_seq.sv"
  `include "tx_config_change_seq.sv"
  `include "tx_config_illegal_seq.sv"

  `include "tx_base_vseq.sv"
  `include "tx_basic_vseq.sv"
  `include "tx_bypass_vseq.sv"
  `include "tx_config_change_vseq.sv"
  `include "tx_bypass_change_vseq.sv"
  `include "tx_reset_vseq.sv"
  `include "tx_illegal_cfg_vseq.sv"

  // drivers
  `include "tx_data_driver.sv"
  `include "tx_config_driver.sv"

  // monitors
  `include "tx_data_monitor.sv"
  `include "tx_config_monitor.sv"
  `include "tx_out_monitor.sv"

  // agents
  `include "tx_data_agent.sv"
  `include "tx_config_agent.sv"
  `include "tx_out_agent.sv"

  // scoreboard & coverage
  `include "tx_scoreboard.sv"
  `include "tx_coverage.sv"

  // env & tests
  `include "tx_env.sv"
  `include "base_test.sv"
  `include "basic_test.sv"
  `include "bypass_test.sv"
  `include "config_change_test.sv"
  `include "bypass_change_test.sv"
  `include "reset_test.sv"
  `include "illegal_config_test.sv"

endpackage
