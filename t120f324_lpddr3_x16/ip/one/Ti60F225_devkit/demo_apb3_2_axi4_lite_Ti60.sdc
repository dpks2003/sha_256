# Device: Ti60F225ES
# Project: demo_apb3_2_axi4_lite
# Timing Model: C3 (final)

# PLL Constraints
#################
create_clock -period 20.00 clk

# GPIO Constraints
####################
# set_input_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {ext_clk}]
# set_input_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {ext_clk}]
# set_input_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {rstn}]
# set_input_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {rstn}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {led_o[0]}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {led_o[0]}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {led_o[1]}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {led_o[1]}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {led_o[2]}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {led_o[2]}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {led_o[3]}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {led_o[3]}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {led_o[4]}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {led_o[4]}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {led_o[5]}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {led_o[5]}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {led_o[6]}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {led_o[6]}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {led_o[7]}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {led_o[7]}]