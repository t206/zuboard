

#E5 spi_1_mosi
#E6 spi_1_miso
#F6 spi_1_sck
#G7 spi_1_csn

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


