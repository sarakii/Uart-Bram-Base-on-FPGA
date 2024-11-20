create_clock -period 10.000 -name sys_clk_p [get_ports sys_clk_p]
#时钟
set_property IOSTANDARD DIFF_HSTL_I_12 [get_ports sys_clk_p]
set_property IOSTANDARD DIFF_HSTL_I_12 [get_ports sys_clk_n]
set_property PACKAGE_PIN AE5 [get_ports sys_clk_p]
set_property PACKAGE_PIN AF5 [get_ports sys_clk_n]
#复位
set_property -dict {PACKAGE_PIN AH11 IOSTANDARD LVCMOS33} [get_ports sys_rst_n]
#串口接收和发送引脚
set_property -dict {PACKAGE_PIN AB9 IOSTANDARD LVCMOS33} [get_ports rx]
set_property -dict {PACKAGE_PIN AB10 IOSTANDARD LVCMOS33} [get_ports tx]