onerror {quit -f}
vlib work
vlog +define+SIM+SIM_MODE+EFX_SIM -sv ./tb_apb3_2_axi4_lite.v
vlog +define+SIM+SIM_MODE+EFX_SIM -sv ./example_design_apb3_2_axi4_lite.v
vlog +define+SIM+SIM_MODE+EFX_SIM -sv ./one.v
vsim -t ns work.tb_apb3_2_axi4_lite
run -all
