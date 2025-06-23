# Set up the libraries
set target_library  {/var/home/fjy3ws/synopsys/lab02_design_compiler/ref/db_nldm/saed14rvt_tt0p8v25c.db   }
set link_library    {* /var/home/fjy3ws/synopsys/lab02_design_compiler/ref/db_nldm/saed14rvt_tt0p8v25c.db }

# Read and analyze the Verilog file
read_verilog mac/adder/add_normalizer.v
read_verilog mac/adder/alignment.v

read_verilog mac/adder/cla_nbit.v
analyze -format verilog mac/adder/cla_nbit.v

read_verilog mac/adder/fp_add.v
read_verilog mac/multiplier/fp_mul.v
read_verilog mac/multiplier/mul16x16.v
read_verilog mac/multiplier/mul2x2.v 
read_verilog mac/multiplier/mul4x4.v
read_verilog mac/multiplier/mul8x8.v
read_verilog mac/multiplier/mul_normalizer.v
read_verilog mac/mac/mac_unit.v
read_verilog skew_registers.v
read_verilog pe_is.v
read_verilog systolic_array_is.v

current_design systolic_array_is
analyze -format verilog systolic_array_is.v
# elaborate verilog systolic_array_is

# Create a clock constraint
create_clock -period 1.25 [get_ports clk]

# Synthesize the design with timing optimization
compile_ultra

# Add clock propagation to simulate post-CTS behavior
set_propagated_clock [get_clocks clk]

# Generate a timing report for the critical paths
report_timing -delay_type max -path_type full_clock_expanded -max_paths 5

# Report area
report_area
# report_hierarchy
# report_cell
# report_reference

# Report Power
report_power

