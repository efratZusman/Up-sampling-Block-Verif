# 1. Initialize simulation with access and coverage enabled
# Use existing test registered in the TB: "basic_test". If you prefer the TB to choose the test
# via run_test("basic_test") you can remove +UVM_TESTNAME entirely.
vsim -c -acdb +access+r +UVM_TESTNAME=basic_test tb_top

# 2. Run the simulation until UVM test finishes (run -all waits until $finish)
run -all

# 3. Save the coverage database (ACDB)
acdb save -o fcover.acdb

# 4. Generate a textual coverage report from the DB
acdb report -db fcover.acdb -txt -o cov.txt

# 5. Print the report to the console
exec cat cov.txt

# 6. Exit simulator
exit
