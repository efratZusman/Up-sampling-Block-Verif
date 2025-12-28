#!/bin/bash
# Local helper: compile once and run each UVM test sequentially (requires Riviera in PATH)
set -e

echo "Compile design"
vlib work
vlog -timescale 1ns/1ps +incdir+$RIVIERA_HOME/vlib/uvm-1.2/src design.sv testbench.sv

tests=(basic_test bypass_test bypass_change_test config_change_test illegal_config_test reset_test)

for t in "${tests[@]}"; do
  echo "\n=== Running test: $t ==="
  vsim -c -acdb +access+r +UVM_TESTNAME=${t} tb_top -do "run -all; acdb save -o fcover_${t}.acdb; acdb report -db fcover_${t}.acdb -txt -o cov_${t}.txt; exec cat cov_${t}.txt; exit"
done

echo "All tests finished. Reports: cov_*.txt, ACDBs: fcover_*.acdb"
