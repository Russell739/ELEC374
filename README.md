# Elec374CPU

## Phase 2 Testbench

Run the Phase 2 ModelSim testbench from the repo root so `tb/phase2_mem_init.hex`
resolves correctly:

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

Expected result:

```text
PASS PHASE2 SUITE
```
