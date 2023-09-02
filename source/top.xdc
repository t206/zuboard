

#E5 spi_1_mosi
#E6 spi_1_miso
#F6 spi_1_sck
#G7 spi_1_csn

set_property IOSTANDARD LVCMOS18  [get_ports {spi_1_*}]
set_property PACKAGE_PIN E5       [get_ports spi_1_mosi]
set_property PACKAGE_PIN E6       [get_ports spi_1_miso]
set_property PACKAGE_PIN F6       [get_ports spi_1_sck]
set_property PACKAGE_PIN G7       [get_ports spi_1_csn]


