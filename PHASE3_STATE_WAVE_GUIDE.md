# Phase 3 State/Wave Guide

This guide maps `dut.UCTRL.state` (from `control_unit.v`) to what you should see in datapath registers during simulation.

## How To Read It

- All register updates happen on the **posedge** of `clk`.
- If a register is not listed as updated for a state, it should hold its prior value.
- `BUS` source is mainly set by `bus_sel`, except when decoded register routing (`Rout_dec`) or `Cout`/`InPortout` overrides it.
- Branch write to `PC` at `S_BR_T6` is conditional on `CON_q=1`.

## Bus Select Reference (`bus_sel`)

- `16`: `PC`
- `20`: `MDR`
- `21`: `HI`
- `22`: `LO`
- `23`: `Zlow`
- `24`: `Zhigh`

## State Encoding

### Fetch / Decode / Halt

| State | Name | Main Assertions | Register Updates At Posedge |
|---|---|---|---|
| `0` | `S_RESET` | none (CU only sets `Run` high) | No datapath write from CU state alone |
| `1` | `S_FETCH0` | `bus_sel=PC`, `MARin`, `IncPC`, `Zin` | `MAR<=PC`, `Z<=PC+1` |
| `2` | `S_FETCH1` | `bus_sel=Zlow`, `PCin`, `Read`, `MDRin` | `PC<=Zlow`, `MDR<=RAM[MAR]` |
| `3` | `S_FETCH2` | `bus_sel=MDR`, `IRin` | `IR<=MDR` |
| `42` | `S_DECODE` | none | No datapath register write |
| `41` | `S_HALT` | none (`Run=0`) | Holds state; no datapath writes expected |

### R-Type ALU Path (`add/sub/and/or/shr/shra/shl/ror/rol`)

| State | Name | Main Assertions | Register Updates At Posedge |
|---|---|---|---|
| `4` | `S_ALU_T3` | `Grb`, `Rout_dec`, `Yin` | `Y<=R[rb]` |
| `5` | `S_ALU_T4` | `Grc`, `Rout_dec`, `op=<alu op>`, `Zin` | `Z<=ALU(Y, R[rc])` |
| `6` | `S_ALU_T5` | `bus_sel=Zlow`, `Gra`, `Rin_dec` | `R[ra]<=Zlow` |

### Unary ALU Path (`neg/not`)

| State | Name | Main Assertions | Register Updates At Posedge |
|---|---|---|---|
| `7` | `S_UNARY_T3` | `Grb`, `Rout_dec`, `op=<neg/not>`, `Zin` | `Z<=ALU(Y, R[rb])` (unary op uses bus operand) |
| `8` | `S_UNARY_T4` | `bus_sel=Zlow`, `Gra`, `Rin_dec` | `R[ra]<=Zlow` |

### Multiply/Divide Path (`mul/div`)

| State | Name | Main Assertions | Register Updates At Posedge |
|---|---|---|---|
| `9` | `S_MD_T3` | `Gra`, `Rout_dec`, `Yin` | `Y<=R[ra]` |
| `10` | `S_MD_T4` | `Grb`, `Rout_dec`, `op=<mul/div>`, `Zin` | `Z<=ALU(Y, R[rb])` (64-bit result) |
| `11` | `S_MD_T5` | `bus_sel=Zlow`, `LOin` | `LO<=Zlow` |
| `12` | `S_MD_T6` | `bus_sel=Zhigh`, `HIin` | `HI<=Zhigh` |

### Load (`ld`)

| State | Name | Main Assertions | Register Updates At Posedge |
|---|---|---|---|
| `13` | `S_LD_T3` | `Grb`, `Rout_dec`, `BAout`, `Yin` | `Y<= (rb==R0 ? 0 : R[rb])` |
| `14` | `S_LD_T4` | `Cout`, `op=ADD`, `Zin` | `Z<=Y + signext(C)` |
| `15` | `S_LD_T5` | `bus_sel=Zlow`, `MARin` | `MAR<=Zlow` |
| `16` | `S_LD_T6` | `Read`, `MDRin` | `MDR<=RAM[MAR]` |
| `17` | `S_LD_T7` | `bus_sel=MDR`, `Gra`, `Rin_dec` | `R[ra]<=MDR` |

### Load Immediate (`ldi`)

| State | Name | Main Assertions | Register Updates At Posedge |
|---|---|---|---|
| `18` | `S_LDI_T3` | `Grb`, `Rout_dec`, `BAout`, `Yin` | `Y<= (rb==R0 ? 0 : R[rb])` |
| `19` | `S_LDI_T4` | `Cout`, `op=ADD`, `Zin` | `Z<=Y + signext(C)` |
| `20` | `S_LDI_T5` | `bus_sel=Zlow`, `Gra`, `Rin_dec` | `R[ra]<=Zlow` |

### Store (`st`)

| State | Name | Main Assertions | Register Updates At Posedge |
|---|---|---|---|
| `21` | `S_ST_T3` | `Gra`, `Rout_dec`, `MDRin` | `MDR<=R[ra]` (store data latched) |
| `22` | `S_ST_T4` | `Grb`, `Rout_dec`, `BAout`, `Yin` | `Y<= (rb==R0 ? 0 : R[rb])` |
| `23` | `S_ST_T5` | `Cout`, `op=ADD`, `Zin` | `Z<=Y + signext(C)` |
| `24` | `S_ST_T6` | `bus_sel=Zlow`, `MARin` | `MAR<=Zlow` |
| `25` | `S_ST_T7` | `Write` | `RAM[MAR]<=MDR` |

### Immediate ALU (`addi/andi/ori`)

| State | Name | Main Assertions | Register Updates At Posedge |
|---|---|---|---|
| `26` | `S_IMM_T3` | `Grb`, `Rout_dec`, `Yin` | `Y<=R[rb]` |
| `27` | `S_IMM_T4` | `Cout`, `op=<add/and/or>`, `Zin` | `Z<=ALU(Y, signext(C))` |
| `28` | `S_IMM_T5` | `bus_sel=Zlow`, `Gra`, `Rin_dec` | `R[ra]<=Zlow` |

### Branch (`brzr/brnz/brpl/brmi`)

| State | Name | Main Assertions | Register Updates At Posedge |
|---|---|---|---|
| `29` | `S_BR_T3` | `Gra`, `Rout_dec`, `CONin` | `CON_q<=cond(R[ra], IR[20:19])` |
| `30` | `S_BR_T4` | `bus_sel=PC`, `Yin` | `Y<=PC` |
| `31` | `S_BR_T5` | `Cout`, `op=ADD`, `Zin` | `Z<=PC + signext(C)` |
| `32` | `S_BR_T6` | `bus_sel=Zlow`, `CON_to_PCin` | `PC<=Zlow` **only if** `CON_q=1`; else PC unchanged |

### Jump / Special / I/O

| State | Name | Main Assertions | Register Updates At Posedge |
|---|---|---|---|
| `33` | `S_JR_T3` | `Gra`, `Rout_dec`, `PCin` | `PC<=R[ra]` |
| `34` | `S_JAL_T3` | `bus_sel=PC`, `Rin[12]=1` | `R12<=PC` (return addr) |
| `35` | `S_JAL_T4` | `Gra`, `Rout_dec`, `PCin` | `PC<=R[ra]` |
| `36` | `S_MFHILO_T3` | `bus_sel=HI/LO`, `Gra`, `Rin_dec` | `R[ra]<=HI` or `R[ra]<=LO` |
| `37` | `S_OUT_T3` | `Gra`, `Rout_dec`, `OutPortin` | `OutPort_q<=R[ra]` |
| `38` | `S_IN_T3` | `InPortLoad` | `InPort_q<=InPort_data` |
| `39` | `S_IN_T4` | `InPortout`, `Gra`, `Rin_dec` | `R[ra]<=InPort_q` |
| `40` | `S_NOP_T3` | none | No datapath register write |

## Opcode -> First Execute State (from `S_DECODE`)

- `add/sub/and/or/shr/shra/shl/ror/rol` -> `S_ALU_T3`
- `neg/not` -> `S_UNARY_T3`
- `mul/div` -> `S_MD_T3`
- `ld/ldi/st` -> `S_LD_T3` / `S_LDI_T3` / `S_ST_T3`
- `addi/andi/ori` -> `S_IMM_T3`
- `br` -> `S_BR_T3`
- `jr` -> `S_JR_T3`
- `jal` -> `S_JAL_T3`
- `mfhi/mflo` -> `S_MFHILO_T3`
- `out/in` -> `S_OUT_T3` / `S_IN_T3`
- `nop` -> `S_NOP_T3`
- `halt` or unknown opcode -> `S_HALT`

