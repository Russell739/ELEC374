radix hex
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_phase2/clk
add wave -noupdate /tb_phase2/reset
add wave -divider {Control}
add wave -noupdate /tb_phase2/Gra
add wave -noupdate /tb_phase2/Grb
add wave -noupdate /tb_phase2/Rin_dec
add wave -noupdate /tb_phase2/Rout_dec
add wave -noupdate /tb_phase2/BAout
add wave -noupdate /tb_phase2/Cout
add wave -noupdate /tb_phase2/CONin
add wave -noupdate /tb_phase2/CON_to_PCin
add wave -noupdate /tb_phase2/Read
add wave -noupdate /tb_phase2/Write
add wave -noupdate /tb_phase2/OutPortin
add wave -noupdate /tb_phase2/InPortout
add wave -noupdate /tb_phase2/InPortLoad
add wave -divider {State}
add wave -noupdate /tb_phase2/BUS
add wave -noupdate /tb_phase2/dut/PC_q_dbg
add wave -noupdate /tb_phase2/dut/IR_q_dbg
add wave -noupdate /tb_phase2/dut/MAR_q
add wave -noupdate /tb_phase2/dut/MDR_q
add wave -noupdate /tb_phase2/dut/Y_q
add wave -noupdate /tb_phase2/dut/Z_q
add wave -divider {Registers}
add wave -noupdate /tb_phase2/dut/R0_q
add wave -noupdate /tb_phase2/dut/R1_q
add wave -noupdate /tb_phase2/dut/R2_q
add wave -noupdate /tb_phase2/dut/R3_q
add wave -noupdate /tb_phase2/dut/R4_q
add wave -noupdate /tb_phase2/dut/R5_q
add wave -noupdate /tb_phase2/dut/R6_q
add wave -noupdate /tb_phase2/dut/R7_q
add wave -noupdate /tb_phase2/dut/R12_q
add wave -divider {Memory And IO}
add wave -noupdate /tb_phase2/MemDbgAddr
add wave -noupdate /tb_phase2/dut/RAM_read_data_dbg
add wave -noupdate /tb_phase2/dut/RAM_dbg_data
add wave -noupdate /tb_phase2/dut/CON_q_dbg
add wave -noupdate /tb_phase2/dut/OutPort_q_dbg
add wave -noupdate /tb_phase2/dut/InPort_q_dbg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
configure wave -namecolwidth 220
configure wave -valuecolwidth 120
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -timelineunits ns
update
