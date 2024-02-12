# This file is a general .xdc for the Basys3 rev B board
# To use it in a project:
# - uncomment the lines corresponding to used pins
# - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

# Clock signal
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
# create_clock -period 10.000 -name sys_clk_pin -waveform {5.000 0.000} -add [get_ports clk]

# Switches
set_property PACKAGE_PIN V17 [get_ports {input[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {input[0]}]
set_property PACKAGE_PIN V16 [get_ports {input[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {input[1]}]
set_property PACKAGE_PIN W16 [get_ports {input[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {input[2]}]
set_property PACKAGE_PIN W17 [get_ports {input[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {input[3]}]
set_property PACKAGE_PIN W15 [get_ports {input[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {input[4]}]
set_property PACKAGE_PIN V15 [get_ports {input[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {input[5]}]
set_property PACKAGE_PIN W14 [get_ports {input[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {input[6]}]
set_property PACKAGE_PIN W13 [get_ports {input[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {input[7]}]
set_property PACKAGE_PIN V2 [get_ports {input[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {input[8]}]
set_property PACKAGE_PIN T3 [get_ports {input[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {input[9]}]
set_property PACKAGE_PIN T2 [get_ports {input[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {input[10]}]
set_property PACKAGE_PIN R3 [get_ports {input[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {input[11]}]
set_property PACKAGE_PIN W2 [get_ports {input[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {input[12]}]
set_property PACKAGE_PIN U1 [get_ports {input[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {input[13]}]
set_property PACKAGE_PIN T1 [get_ports {input[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {input[14]}]
set_property PACKAGE_PIN R2 [get_ports {input[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {input[15]}]


# LEDs
set_property PACKAGE_PIN U16 [get_ports hit]
set_property IOSTANDARD LVCMOS33 [get_ports hit]
set_property PACKAGE_PIN E19 [get_ports miss]
set_property IOSTANDARD LVCMOS33 [get_ports miss]
#set_property PACKAGE_PIN U19 [get_ports {display_data[2]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {display_data[2]}]
#set_property PACKAGE_PIN V19 [get_ports {display_data[3]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {display_data[3]}]
#set_property PACKAGE_PIN W18 [get_ports {display_data[4]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {display_data[4]}]
#set_property PACKAGE_PIN U15 [get_ports {display_data[5]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {display_data[5]}]
#set_property PACKAGE_PIN U14 [get_ports {display_data[6]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {display_data[6]}]
#set_property PACKAGE_PIN V14 [get_ports {display_data[7]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {display_data[7]}]
#set_property PACKAGE_PIN V13 [get_ports {display_data[8]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {display_data[8]}]
#set_property PACKAGE_PIN V3 [get_ports {display_data[9]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {display_data[9]}]
#set_property PACKAGE_PIN W3 [get_ports {display_data[10]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {display_data[10]}]
#set_property PACKAGE_PIN U3 [get_ports {display_data[11]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {display_data[11]}]
#set_property PACKAGE_PIN P3 [get_ports {display_data[12]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {display_data[12]}]
#set_property PACKAGE_PIN N3 [get_ports {display_data[13]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {display_data[13]}]
#set_property PACKAGE_PIN P1 [get_ports {display_data[14]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {display_data[14]}]
#set_property PACKAGE_PIN L1 [get_ports {display_data[15]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {display_data[15]}]


#7 catment display
set_property PACKAGE_PIN W7 [get_ports {cat[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cat[0]}]
set_property PACKAGE_PIN W6 [get_ports {cat[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cat[1]}]
set_property PACKAGE_PIN U8 [get_ports {cat[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cat[2]}]
set_property PACKAGE_PIN V8 [get_ports {cat[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cat[3]}]
set_property PACKAGE_PIN U5 [get_ports {cat[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cat[4]}]
set_property PACKAGE_PIN V5 [get_ports {cat[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cat[5]}]
set_property PACKAGE_PIN U7 [get_ports {cat[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cat[6]}]


# 7seg display anodes
set_property PACKAGE_PIN U2 [get_ports {an[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]
set_property PACKAGE_PIN U4 [get_ports {an[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]
set_property PACKAGE_PIN V4 [get_ports {an[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]
set_property PACKAGE_PIN W4 [get_ports {an[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]


#Buttons
set_property PACKAGE_PIN U18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]
set_property PACKAGE_PIN T18 [get_ports {btn_test}]
	set_property IOSTANDARD LVCMOS33 [get_ports {btn_test}]
#set_property PACKAGE_PIN W19 [get_ports {btn[2]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {btn[2]}]
#set_property PACKAGE_PIN T17 [get_ports btn[3]]
#	set_property IOSTANDARD LVCMOS33 [get_ports {btn[3]}]
#set_property PACKAGE_PIN U17 [get_ports {btn[4]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {btn[4]}]




