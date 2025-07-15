# Author: Hoang Tien Duc
# Company: Faraday Technology Vietnam Corporation Limited
# Title: Synopsys Design Constraints for AXI4 Data Width Adapter (Upsizer)
# Created on 9th October 2024
# Modified by Hoang Tien Duc, date 9/10/24

########################## Parameters ##########################
set clk_speed       200
set clk_period      [expr (1000.0 / $clk_speed)]
################################################################


######################## Clock Settings ########################
create_clock -name clk -period $clk_period -waveform "0.0 [expr ($clk_period / 2.0)]" [get_ports aclk]

set_clock_uncertainty [expr (1000.0 / $clk_speed)*0.21] [get_clock clk]

set_ideal_network [get_ports aclk]

set_clock_latency 0.02 [get_clock clk]

set_dont_touch_network [get_clock clk]

set_clock_transition 0.01 [get_clock clk]
################################################################


######################## Reset Settings ########################
set_ideal_network [get_ports arst_n]

set_ideal_latency 0.2 [get_ports arst_n]

set_dont_touch_network [get_port arst_n]
################################################################


#################### Virtual Clock Settings ####################
create_clock -name clk_virt -period $clk_period -waveform "0.0 [expr ($clk_period / 2.0)]"

set_clock_uncertainty [expr (1000.0 / $clk_speed)*0.21] [get_clock clk_virt]

set_clock_latency 0.02 -source clk_virt

set_dont_touch_network [get_clock clk_virt]
################################################################


################### Design Rule Constraints ####################
set_max_fanout 32 [get_designs upsizer]
set_timing_derate 1.08 -data -late -net_delay
# set_max_area 0
################################################################


######################### Input Delay ##########################
set_input_delay -clock clk_virt -max [expr (1000.0 / $clk_speed)*0.6] [get_ports { *_i }]
set_input_delay -clock clk_virt -min [expr (1000.0 / $clk_speed)*0.4] [get_ports { *_i }]
set_input_delay -clock clk_virt -max [expr (1000.0 / $clk_speed)*0.6] [get_ports arst_n]
set_input_delay -clock clk_virt -min [expr (1000.0 / $clk_speed)*0.4] [get_ports arst_n]

set_max_capacitance 0.05 [get_ports { *_i }]
set_input_transition 0.01 [get_ports { *_i }]
################################################################


######################## Output Delay #########################
set_output_delay -clock clk_virt -max [expr (1000.0 / $clk_speed)*0.6] [get_ports { *_o }]
set_output_delay -clock clk_virt -min [expr (1000.0 / $clk_speed)*0.4] [get_ports { *_o }]

set_load 0.03 [get_ports { *_o }]
set_max_capacitance 0.05 [get_ports { *_o }]
################################################################