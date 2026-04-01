# Phase 3 – Compile, Load, Add Waves, Run
# Usage:  Open ModelSim → cd to project root → do simulation/modelsim/run_phase3.do

# ---------- Compile ----------
vlib work_phase3
vlog -work work_phase3 +incdir+datapath \
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
  tb/tb_phase3_cpu.v

# ---------- Load ----------
vsim work_phase3.tb_phase3_cpu

# ---------- Add waveforms ----------
do simulation/modelsim/phase3_wave.do

# ---------- Run ----------
run -all
