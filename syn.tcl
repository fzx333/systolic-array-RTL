# Set up the libraries
set target_library  {/var/home/fjy3ws/synopsys/lab02_design_compiler/ref/db_nldm/saed14rvt_tt0p8v25c.db   }
set link_library    {* /var/home/fjy3ws/synopsys/lab02_design_compiler/ref/db_nldm/saed14rvt_tt0p8v25c.db }

# Read and analyze the Verilog file
read_verilog mac/adder/*.v
read_verilog mac/multiplier/*.v
read_verilog mac/mac_unit.v
read_verilog skew_registers.v
read_verilog systolic_array_is.v

current_design systolic_array_is

analyze -format verilog systolic_array_is.v
# elaborate pe_top_module

# Create a clock constraint
create_clock -period 1.25 [get_ports clk]

# Synthesize the design with timing optimization
compile_ultra

# Generate a timing report for the critical paths
report_timing -delay_type max -path_type full_clock_expanded -max_paths 5

# Report area
report_area

# Report Power
report_power

