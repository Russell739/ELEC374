# Phase 4 Demo Waveform Configuration

delete wave *

# ========== Clock / Reset / Stop / Run ==========
add wave -divider "CLOCK & CONTROL"
add wave                          /tb_phase4_cpu/clk
add wave                          /tb_phase4_cpu/reset
add wave                          /tb_phase4_cpu/stop
add wave                          /tb_phase4_cpu/run

# ========== FSM State & Cycle Count ==========
add wave -divider "STATE"
add wave -radix unsigned          /tb_phase4_cpu/dut/UCTRL/state
add wave -radix unsigned          /tb_phase4_cpu/cycles

# ========== Registers R0 - R15 ==========
add wave -divider "REGISTERS R0-R15"
add wave -radix hexadecimal       /tb_phase4_cpu/dut/UDATAPATH/R\[0\]
add wave -radix hexadecimal       /tb_phase4_cpu/dut/UDATAPATH/R\[1\]
add wave -radix hexadecimal       /tb_phase4_cpu/r2_dbg
add wave -radix hexadecimal       /tb_phase4_cpu/r3_dbg
add wave -radix hexadecimal       /tb_phase4_cpu/dut/UDATAPATH/R\[4\]
add wave -radix hexadecimal       /tb_phase4_cpu/r5_dbg
add wave -radix hexadecimal       /tb_phase4_cpu/r6_dbg
add wave -radix hexadecimal       /tb_phase4_cpu/r7_dbg
add wave -radix hexadecimal       /tb_phase4_cpu/dut/UDATAPATH/R\[8\]
add wave -radix hexadecimal       /tb_phase4_cpu/dut/UDATAPATH/R\[9\]
add wave -radix hexadecimal       /tb_phase4_cpu/dut/UDATAPATH/R\[10\]
add wave -radix hexadecimal       /tb_phase4_cpu/dut/UDATAPATH/R\[11\]
add wave -radix hexadecimal       /tb_phase4_cpu/r12_dbg
add wave -radix hexadecimal       /tb_phase4_cpu/dut/UDATAPATH/R\[13\]
add wave -radix hexadecimal       /tb_phase4_cpu/dut/UDATAPATH/R\[14\]
add wave -radix hexadecimal       /tb_phase4_cpu/dut/UDATAPATH/R\[15\]

# ========== Special Registers ==========
add wave -divider "SPECIAL REGISTERS"
add wave -radix hexadecimal       /tb_phase4_cpu/ir_dbg
add wave -radix hexadecimal       /tb_phase4_cpu/dut/UDATAPATH/PC_q
add wave -radix hexadecimal       /tb_phase4_cpu/hi_dbg
add wave -radix hexadecimal       /tb_phase4_cpu/lo_dbg
add wave -radix hexadecimal       /tb_phase4_cpu/dut/UDATAPATH/MDR_q
add wave -radix hexadecimal       /tb_phase4_cpu/dut/UDATAPATH/MAR_q
add wave -radix hexadecimal       /tb_phase4_cpu/dut/UDATAPATH/Y_q
add wave -radix hexadecimal       /tb_phase4_cpu/dut/UDATAPATH/Z_q

# ========== Bus ==========
add wave -divider "BUS"
add wave -radix hexadecimal       /tb_phase4_cpu/dut/UDATAPATH/BUS
add wave -radix unsigned          /tb_phase4_cpu/dut/UCTRL/bus_sel
add wave -radix hexadecimal       /tb_phase4_cpu/dut/UDATAPATH/ram_read_data

# ========== ALU ==========
add wave -divider "ALU"
add wave -radix unsigned          /tb_phase4_cpu/dut/UCTRL/op

# ========== Condition ==========
add wave -divider "CONDITION"
add wave                          /tb_phase4_cpu/dut/UCTRL/CONin
add wave                          /tb_phase4_cpu/dut/UDATAPATH/CON_q
add wave                          /tb_phase4_cpu/dut/UCTRL/CON_to_PCin

# ========== Select & Encode ==========
add wave -divider "SELECT / ENCODE"
add wave                          /tb_phase4_cpu/dut/UCTRL/Rout_dec
add wave -radix binary            /tb_phase4_cpu/dut/UDATAPATH/Rout_decoded
add wave                          /tb_phase4_cpu/dut/UCTRL/Rin_dec
add wave -radix binary            /tb_phase4_cpu/dut/UDATAPATH/Rin_decoded
add wave -radix binary            /tb_phase4_cpu/dut/UCTRL/Rin

# ========== Control Signals ==========
add wave -divider "CONTROL SIGNALS"
add wave                          /tb_phase4_cpu/dut/UCTRL/Cout
add wave                          /tb_phase4_cpu/dut/UCTRL/Yin
add wave                          /tb_phase4_cpu/dut/UCTRL/Zin
add wave                          /tb_phase4_cpu/dut/UCTRL/Gra
add wave                          /tb_phase4_cpu/dut/UCTRL/Grb
add wave                          /tb_phase4_cpu/dut/UCTRL/Grc
add wave                          /tb_phase4_cpu/dut/UCTRL/IncPC
add wave                          /tb_phase4_cpu/dut/UCTRL/BAout
add wave                          /tb_phase4_cpu/dut/UCTRL/HIin
add wave                          /tb_phase4_cpu/dut/UCTRL/LOin
add wave                          /tb_phase4_cpu/dut/UCTRL/IRin
add wave                          /tb_phase4_cpu/dut/UCTRL/MARin
add wave                          /tb_phase4_cpu/dut/UCTRL/MDRin
add wave                          /tb_phase4_cpu/dut/UCTRL/PCin
add wave                          /tb_phase4_cpu/dut/UCTRL/Read
add wave                          /tb_phase4_cpu/dut/UCTRL/Write

# ========== I/O (Phase 4 specific) ==========
add wave -divider "I/O PORTS"
add wave -radix hexadecimal       /tb_phase4_cpu/out_port_dbg
add wave -radix hexadecimal       /tb_phase4_cpu/in_port_data
add wave                          /tb_phase4_cpu/dut/UCTRL/OutPortin
add wave                          /tb_phase4_cpu/dut/UCTRL/InPortout
add wave                          /tb_phase4_cpu/dut/UCTRL/InPortLoad

configure wave -namecolwidth 260
configure wave -valuecolwidth 120
WaveRestoreZoom {0 ns} {53000 ns}
