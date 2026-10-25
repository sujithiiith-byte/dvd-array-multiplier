# OpenSTA script for mult_array (typical corner tt_025C_1v80)
# Run from the repository root:  sta sta/sta.tcl
# Clock period T defaults to 10 ns; override with:  T=2.5 sta sta/sta.tcl

set lib $::env(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

if {[info exists ::env(T)]} {
    set T $::env(T)
} else {
    set T 10.0
}
puts "Clock period T = $T ns"

read_liberty $lib

read_verilog synth/mult_array_netlist.v
link_design mult_array

create_clock -name clk -period $T [get_ports clk]

set_input_delay 1.0 -clock clk [delete_from_list [all_inputs] [get_ports clk]]

set_output_delay 1.0 -clock clk [all_outputs]

report_worst_slack -max


report_checks -path_delay max -digits 3 > sta/mult_array_timing.rpt

exit
