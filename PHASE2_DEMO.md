# Phase 2 Demo Helper

Run the phase 2 testbench from the repo root so the memory init file resolves correctly:

```powershell
vlib $env:TEMP\elec374_phase2_work
vmap phase2lib $env:TEMP\elec374_phase2_work
vlog -work phase2lib +incdir+datapath `
  datapath/defines.vh `
  datapath/register32.v datapath/register64.v `
  datapath/cla4.v datapath/cla32.v `
  datapath/booth_bit_pair.v datapath/nonrestoring_div32.v `
  datapath/alu_logic.v datapath/bus_mux.v `
  datapath/select_encode.v datapath/sign_extend_c.v `
  datapath/con_ff_logic.v datapath/io_ports.v `
  datapath/ram512x32.v datapath/datapath_logic.v `
  tb/tb_phase2.v
vsim -c phase2lib.tb_phase2 -do "run -all; quit -f"
```

Expected terminal result:

```text
PASS PHASE2 SUITE
```

## Signals To Show In The Waveform

- `clk`, `reset`
- `dut.PC_q_dbg`, `dut.IR_q_dbg`, `dut.MAR_q`, `dut.MDR_q`
- `dut.BUS`, `dut.Y_q`, `dut.Z_q[31:0]`
- `dut.R0_q`, `dut.R1_q`, `dut.R2_q`, `dut.R3_q`, `dut.R4_q`, `dut.R5_q`, `dut.R6_q`, `dut.R7_q`, `dut.R12_q`
- `dut.RAM_read_data_dbg`, `dut.RAM_dbg_data`, `MemDbgAddr`
- `dut.CON_q_dbg`
- `dut.OutPort_q_dbg`, `dut.InPort_q_dbg`
- `Gra`, `Grb`, `Rin_dec`, `Rout_dec`, `BAout`, `Cout`, `CONin`, `CON_to_PCin`, `Read`, `Write`, `OutPortin`, `InPortout`, `InPortLoad`

## What To Point Out

- Fetch `T0-T2`: `PC -> MAR`, `PC + 1 -> Zlow -> PC`, `MDR -> IR`
- Direct vs indexed addressing: `BAout` forces `R0` to put `0` on the bus, while nonzero `Rb` contributes its register value
- Sign extension: `Cout` drives the sign-extended `C` field onto the bus
- Store verification: show the target memory contents before and after `st`
- Branch verification: show both taken and not-taken cases and the value latched into `CON_q_dbg`
- I/O verification: `OutPort_q_dbg` updates on `out`, `InPort_q_dbg` latches external input before `in`

## Demo Checklist

- `3.1` `ld R7, 0x65` and `ld R0, 0x72(R2)`
- `3.1` `ldi R7, 0x65` and `ldi R0, 0x72(R2)`
- `3.2` `st 0x1F, R6` and `st 0x1F(R6), R6`
- `3.3` `addi R7, R4, -9`, `andi R7, R4, 0x71`, `ori R7, R4, 0x71`
- `3.4` `brzr`, `brnz`, `brpl`, `brmi` with taken and not-taken outcomes
- `3.5` `jr R12` and `jal R4`
- `3.6` `mfhi R5` and `mflo R1`
- `3.7` `out R7` and `in R5`

## Spec-Correct Fetch Words To Expect

- `ld R7, 0x65` -> `0x83800065`
- `ld R0, 0x72(R2)` -> `0x80100072`
- `ldi R7, 0x65` -> `0x8B800065`
- `ldi R0, 0x72(R2)` -> `0x88100072`
- `st 0x1F, R6` -> `0x9300001F`
- `st 0x1F(R6), R6` -> `0x9330001F`
- `addi R7, R4, -9` -> `0x4BA7FFF7`
- `andi R7, R4, 0x71` -> `0x53A00071`
- `ori R7, R4, 0x71` -> `0x5BA00071`
- `brzr R3, 48` -> `0xA9800030`
- `brnz R3, 48` -> `0xA9880030`
- `brpl R3, 48` -> `0xA9900030`
- `brmi R3, 48` -> `0xA9980030`
- `jr R12` -> `0xA6000000`
- `jal R4` -> `0x9A000000`
- `mfhi R5` -> `0xC2800000`
- `mflo R1` -> `0xC8800000`
- `out R7` -> `0xBB800000`
- `in R5` -> `0xB2800000`
