# Phase 3 Demo Waveform Configuration
# Usage: after vsim, run "do simulation/modelsim/phase3_wave.do"

# Remove any existing waves
delete wave *

# ========== Clock / Reset / Stop / Run ==========
add wave -divider "CLOCK & CONTROL"
add wave                          /tb_phase3_cpu/clk
add wave                          /tb_phase3_cpu/reset
add wave                          /tb_phase3_cpu/stop
add wave                          /tb_phase3_cpu/run

# ========== FSM State & Cycle Count ==========
add wave -divider "STATE"
add wave -radix unsigned          /tb_phase3_cpu/dut/UCTRL/state
add wave -radix unsigned          /tb_phase3_cpu/cycles

# ========== Registers R0 – R15 ==========
add wave -divider "REGISTERS R0-R15"
add wave -radix hexadecimal       /tb_phase3_cpu/r0_dbg
add wave -radix hexadecimal       /tb_phase3_cpu/r1_dbg
add wave -radix hexadecimal       /tb_phase3_cpu/r2_dbg
add wave -radix hexadecimal       /tb_phase3_cpu/r3_dbg
add wave -radix hexadecimal       /tb_phase3_cpu/r4_dbg
add wave -radix hexadecimal       /tb_phase3_cpu/r5_dbg
add wave -radix hexadecimal       /tb_phase3_cpu/r6_dbg
add wave -radix hexadecimal       /tb_phase3_cpu/r7_dbg
add wave -radix hexadecimal       /tb_phase3_cpu/r8_dbg
add wave -radix hexadecimal       /tb_phase3_cpu/r9_dbg
add wave -radix hexadecimal       /tb_phase3_cpu/r10_dbg
add wave -radix hexadecimal       /tb_phase3_cpu/r11_dbg
add wave -radix hexadecimal       /tb_phase3_cpu/r12_dbg
add wave -radix hexadecimal       /tb_phase3_cpu/r13_dbg
add wave -radix hexadecimal       /tb_phase3_cpu/r14_dbg
add wave -radix hexadecimal       /tb_phase3_cpu/r15_dbg

# ========== Special Registers ==========
add wave -divider "SPECIAL REGISTERS"
add wave -radix hexadecimal       /tb_phase3_cpu/ir_dbg
add wave -radix hexadecimal       /tb_phase3_cpu/pc_dbg
add wave -radix hexadecimal       /tb_phase3_cpu/hi_dbg
add wave -radix hexadecimal       /tb_phase3_cpu/lo_dbg
add wave -radix hexadecimal       /tb_phase3_cpu/mdr_dbg
add wave -radix hexadecimal       /tb_phase3_cpu/mar_dbg
add wave -radix hexadecimal       /tb_phase3_cpu/y_dbg
add wave -radix hexadecimal       /tb_phase3_cpu/z_dbg

# ========== Bus ==========
add wave -divider "BUS"
add wave -radix hexadecimal       /tb_phase3_cpu/bus_dbg
add wave -radix unsigned          /tb_phase3_cpu/dut/UCTRL/bus_sel
add wave -radix hexadecimal       /tb_phase3_cpu/ram_read_data_dbg

# ========== ALU Op ==========
add wave -divider "ALU"
add wave -radix unsigned          /tb_phase3_cpu/dut/UCTRL/op

# ========== Condition Logic ==========
add wave -divider "CONDITION"
add wave                          /tb_phase3_cpu/dut/UCTRL/CONin
add wave                          /tb_phase3_cpu/con_dbg
add wave                          /tb_phase3_cpu/dut/UCTRL/CON_to_PCin

# ========== Select & Encode ==========
add wave -divider "SELECT / ENCODE"
add wave                          /tb_phase3_cpu/dut/UCTRL/Rout_dec
add wave -radix binary            /tb_phase3_cpu/dut/UDATAPATH/Rout_decoded
add wave                          /tb_phase3_cpu/dut/UCTRL/Rin_dec
add wave -radix binary            /tb_phase3_cpu/dut/UDATAPATH/Rin_decoded
add wave -radix binary            /tb_phase3_cpu/dut/UCTRL/Rin

# ========== Control Signals ==========
add wave -divider "CONTROL SIGNALS"
add wave                          /tb_phase3_cpu/dut/UCTRL/Cout
add wave                          /tb_phase3_cpu/dut/UCTRL/Yin
add wave                          /tb_phase3_cpu/dut/UCTRL/Zin
add wave                          /tb_phase3_cpu/dut/UCTRL/Gra
add wave                          /tb_phase3_cpu/dut/UCTRL/Grb
add wave                          /tb_phase3_cpu/dut/UCTRL/Grc
add wave                          /tb_phase3_cpu/dut/UCTRL/IncPC
add wave                          /tb_phase3_cpu/dut/UCTRL/BAout
add wave                          /tb_phase3_cpu/dut/UCTRL/HIin
add wave                          /tb_phase3_cpu/dut/UCTRL/LOin
add wave                          /tb_phase3_cpu/dut/UCTRL/IRin
add wave                          /tb_phase3_cpu/dut/UCTRL/MARin
add wave                          /tb_phase3_cpu/dut/UCTRL/MDRin
add wave                          /tb_phase3_cpu/dut/UCTRL/PCin
add wave                          /tb_phase3_cpu/dut/UCTRL/Read
add wave                          /tb_phase3_cpu/dut/UCTRL/Write

configure wave -namecolwidth 260
configure wave -valuecolwidth 120
WaveRestoreZoom {0 ns} {3200 ns}
