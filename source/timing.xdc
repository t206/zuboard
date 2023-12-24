
create_clock -period 5.0 -name zmod_clk_in_p [get_ports {zmod_clk_in_p}]

#set zmod_mindel -0.2
#set zmod_maxdel +0.2
#set_input_delay -clock [get_clocks {zmod_clk_in_p}] -clock_fall  -min -add_delay $zmod_mindel [get_ports {zmod_d_in_p[*]}]
#set_input_delay -clock [get_clocks {zmod_clk_in_p}] -clock_fall  -max -add_delay $zmod_maxdel [get_ports {zmod_d_in_p[*]}]
#set_input_delay -clock [get_clocks {zmod_clk_in_p}]              -min -add_delay $zmod_mindel [get_ports {zmod_d_in_p[*]}]
#set_input_delay -clock [get_clocks {zmod_clk_in_p}]              -max -add_delay $zmod_maxdel [get_ports {zmod_d_in_p[*]}]


#set zmod_period 5.0
#set zmod_mindel [expr {[expr{$zmod_period/2}] - 0.2}]
#set zmod_maxdel [expr {[expr{$zmod_period/2}] + 0.2}]
#set_input_delay -clock [get_clocks {zmod_clk_in_p}] -clock_fall -min -add_delay $zmod_mindel [get_ports {zmod_d_in_p[*]}]
#set_input_delay -clock [get_clocks {zmod_clk_in_p}] -clock_fall -max -add_delay $zmod_maxdel [get_ports {zmod_d_in_p[*]}]
#set_input_delay -clock [get_clocks {zmod_clk_in_p}]             -min -add_delay $zmod_mindel [get_ports {zmod_d_in_p[*]}]
#set_input_delay -clock [get_clocks {zmod_clk_in_p}]             -max -add_delay $zmod_maxdel [get_ports {zmod_d_in_p[*]}]

#set zmod_mindel 2.3
#set zmod_maxdel 2.7
set zmod_mindel -0.1
set zmod_maxdel +0.1
set_input_delay -clock [get_clocks {zmod_clk_in_p}] -clock_fall -min -add_delay $zmod_mindel [get_ports {zmod_d_in_p[*]}]
set_input_delay -clock [get_clocks {zmod_clk_in_p}] -clock_fall -max -add_delay $zmod_maxdel [get_ports {zmod_d_in_p[*]}]
set_input_delay -clock [get_clocks {zmod_clk_in_p}]             -min -add_delay $zmod_mindel [get_ports {zmod_d_in_p[*]}]
set_input_delay -clock [get_clocks {zmod_clk_in_p}]             -max -add_delay $zmod_maxdel [get_ports {zmod_d_in_p[*]}]



create_generated_clock -name zmod_clk_out -divide_by 1 -source [get_pins zmod_test_inst/ODDRE1_clk_out/C] [get_ports zmod_clk_out_p]
set_output_delay -clock [get_clocks {zmod_clk_out}] -clock_fall -min -add_delay 0.1     [get_ports {zmod_d_out_n[*]}]
set_output_delay -clock [get_clocks {zmod_clk_out}] -clock_fall -max -add_delay 1.15    [get_ports {zmod_d_out_n[*]}]
set_output_delay -clock [get_clocks {zmod_clk_out}]             -min -add_delay 0.1     [get_ports {zmod_d_out_n[*]}]
set_output_delay -clock [get_clocks {zmod_clk_out}]             -max -add_delay 1.15    [get_ports {zmod_d_out_n[*]}]
