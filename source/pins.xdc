


set_property IOSTANDARD LVCMOS18  [get_ports {spi_1_*}]
set_property PACKAGE_PIN E5       [get_ports spi_1_mosi]
set_property PACKAGE_PIN E6       [get_ports spi_1_miso]
set_property PACKAGE_PIN F6       [get_ports spi_1_sck]
set_property PACKAGE_PIN G7       [get_ports spi_1_csn]


set_property IOSTANDARD LVCMOS18  [get_ports {led2_*}]
set_property IOSTANDARD LVCMOS18  [get_ports {led1_*}]
set_property PACKAGE_PIN A7       [get_ports led1_red]
set_property PACKAGE_PIN B6       [get_ports led1_green]
set_property PACKAGE_PIN B5       [get_ports led1_blue]
set_property PACKAGE_PIN B4       [get_ports led2_red]
set_property PACKAGE_PIN A2       [get_ports led2_green]
set_property PACKAGE_PIN F4       [get_ports led2_blue]

set_property IOSTANDARD LVCMOS18    [get_ports {temp_i2c_*}]
set_property PACKAGE_PIN A6         [get_ports temp_i2c_scl] 
set_property PACKAGE_PIN B7         [get_ports temp_i2c_sda] 

create_clock -period 2.5 -name zmod_clk_in -waveform {0.000 1.25} [get_ports {zmod_clk_in_p}]

set zmod_mindel -0.2
set zmod_maxdel +0.2
set_input_delay -clock [get_clocks {zmod_clk_in}] -clock_fall  -min -add_delay $zmod_mindel [get_ports {zmod_d_in_p[*]}]
set_input_delay -clock [get_clocks {zmod_clk_in}] -clock_fall  -max -add_delay $zmod_maxdel [get_ports {zmod_d_in_p[*]}]
set_input_delay -clock [get_clocks {zmod_clk_in}]              -min -add_delay $zmod_mindel [get_ports {zmod_d_in_p[*]}]
set_input_delay -clock [get_clocks {zmod_clk_in}]              -max -add_delay $zmod_maxdel [get_ports {zmod_d_in_p[*]}]

set_property IOSTANDARD LVDS    [get_ports {zmod_*}]
set_property PACKAGE_PIN B2     [get_ports zmod_clk_out_p]
set_property PACKAGE_PIN U2     [get_ports zmod_d_out_p[3]]
set_property PACKAGE_PIN K4     [get_ports zmod_d_out_p[2]]
set_property PACKAGE_PIN P5     [get_ports zmod_d_out_p[1]]
set_property PACKAGE_PIN P3     [get_ports zmod_d_out_p[0]]
set_property DIFF_TERM TRUE     [get_ports {zmod_clk_in_*}]
set_property DIFF_TERM TRUE     [get_ports {zmod_d_in_*}]
set_property PACKAGE_PIN A4     [get_ports zmod_clk_in_p]
set_property PACKAGE_PIN T3     [get_ports zmod_d_in_p[3]]
set_property PACKAGE_PIN R1     [get_ports zmod_d_in_p[2]]
set_property PACKAGE_PIN K1     [get_ports zmod_d_in_p[1]]
set_property PACKAGE_PIN R4     [get_ports zmod_d_in_p[0]]

