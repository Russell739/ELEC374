# Phase 4 Demo - compile, load, wave, run
# Usage: do simulation/modelsim/run_phase4.do

vlib work_phase4

vlog -reportprogress 300 -work work_phase4 +incdir+datapath \
  datapath/Memory/register32.v \
  datapath/Memory/register64.v \
  datapath/alu/cla4.v \
  datapath/alu/cla32.v \
  datapath/alu/booth_bit_pair.v \
  datapath/alu/nonrestoring_div32.v \
  datapath/alu/alu_logic.v \
  datapath/bus_mux.v \
  datapath/select_encode.v \
  datapath/sign_extend_c.v \
  datapath/con_ff_logic.v \
  datapath/io_ports.v \
  datapath/Memory/ram512x32.v \
  datapath/datapath_logic.v \
  datapath/control_unit.v \
  datapath/cpu_phase3.v \
  datapath/seven_seg_hex.v \
  datapath/cpu_phase4_top.v \
  tb/tb_phase4_cpu.v

vsim work_phase4.tb_phase4_cpu

do simulation/modelsim/phase4_wave.do

run -all
