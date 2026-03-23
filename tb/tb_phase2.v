`timescale 1ns/1ps
`include "defines.vh"

module tb_phase2;
  reg clk = 1'b0;
  always #5 clk = ~clk;

  reg         reset;
  reg  [4:0]  bus_sel;
  reg  [15:0] Rin;
  reg         Yin, Zin;
  reg         PCin, IRin, MARin, MDRin, HIin, LOin, IncPC, Read, Write;
  reg  [3:0]  op;
  reg  [31:0] Mdatain;
  reg  [31:0] PC, IR, HI, LO, MAR, MDR;

  reg         Gra, Grb, Grc, Rin_dec, Rout_dec, BAout, Cout;
  reg         CONin, CON_to_PCin;
  reg         OutPortin, InPortout, InPortLoad;
  reg  [31:0] InPort_data;
  reg         UseRAM;
  reg  [8:0]  MemDbgAddr;

  wire [31:0] BUS;
  wire [31:0] R5_q, R6_q, R3_q, R2_q, R0_q, R1_q, R4_q, R12_q, R7_q;
  wire [31:0] HI_q_dbg, LO_q_dbg, IR_q_dbg, PC_q_dbg, Y_q;
  wire [63:0] Z_q;
  wire        CON_q_dbg;
  wire [31:0] OutPort_q_dbg, InPort_q_dbg, RAM_read_data_dbg, RAM_dbg_data;

  localparam [4:0] SEL_R0    = 5'd0;
  localparam [4:0] SEL_R1    = 5'd1;
  localparam [4:0] SEL_R4    = 5'd4;
  localparam [4:0] SEL_R5    = 5'd5;
  localparam [4:0] SEL_R6    = 5'd6;
  localparam [4:0] SEL_R7    = 5'd7;
  localparam [4:0] SEL_R12   = 5'd12;
  localparam [4:0] SEL_PC    = 5'd16;
  localparam [4:0] SEL_MDR   = 5'd20;
  localparam [4:0] SEL_HI    = 5'd21;
  localparam [4:0] SEL_LO    = 5'd22;
  localparam [4:0] SEL_ZLOW  = 5'd23;

  integer failures;

  datapath_logic #(
    .MEM_INIT_FILE("tb/phase2_mem_init.hex")
  ) dut (
    .clk(clk), .reset(reset),
    .bus_sel(bus_sel), .Rin(Rin), .Yin(Yin), .Zin(Zin),
    .PCin(PCin), .IRin(IRin), .MARin(MARin), .MDRin(MDRin),
    .HIin(HIin), .LOin(LOin), .IncPC(IncPC), .Read(Read), .Write(Write), .Mdatain(Mdatain),
    .Gra(Gra), .Grb(Grb), .Grc(Grc), .Rin_dec(Rin_dec), .Rout_dec(Rout_dec), .BAout(BAout), .Cout(Cout),
    .CONin(CONin), .CON_to_PCin(CON_to_PCin),
    .OutPortin(OutPortin), .InPortout(InPortout), .InPortLoad(InPortLoad), .InPort_data(InPort_data),
    .UseRAM(UseRAM), .MemDbgAddr(MemDbgAddr),
    .PC(PC), .IR(IR), .HI(HI), .LO(LO), .MAR(MAR), .MDR(MDR),
    .op(op),
    .BUS(BUS),
    .R5_q(R5_q), .R6_q(R6_q), .R3_q(R3_q), .R2_q(R2_q),
    .R0_q(R0_q), .R1_q(R1_q), .R4_q(R4_q), .R12_q(R12_q), .R7_q(R7_q),
    .HI_q_dbg(HI_q_dbg), .LO_q_dbg(LO_q_dbg), .IR_q_dbg(IR_q_dbg), .PC_q_dbg(PC_q_dbg),
    .Y_q(Y_q), .Z_q(Z_q),
    .CON_q_dbg(CON_q_dbg), .OutPort_q_dbg(OutPort_q_dbg), .InPort_q_dbg(InPort_q_dbg),
    .RAM_read_data_dbg(RAM_read_data_dbg), .RAM_dbg_data(RAM_dbg_data)
  );

  function [31:0] mk_ir_imm;
    input [4:0] op5;
    input [3:0] ra;
    input [3:0] rb;
    input [18:0] c;
    begin
      mk_ir_imm = {op5, ra, rb, c};
    end
  endfunction

  function [31:0] mk_ir_branch;
    input [4:0] op5;
    input [3:0] ra;
    input [1:0] c2;
    input [18:0] c;
    begin
      mk_ir_branch = {op5, ra, 2'b00, c2, c};
    end
  endfunction

  function [31:0] mk_ir_rrr;
    input [4:0] op5;
    input [3:0] ra;
    input [3:0] rb;
    input [3:0] rc;
    begin
      mk_ir_rrr = {op5, ra, rb, rc, 15'b0};
    end
  endfunction

  task clear_ctrl;
    begin
      bus_sel     = 5'd0;
      Rin         = 16'b0;
      Yin         = 1'b0;
      Zin         = 1'b0;
      PCin        = 1'b0;
      IRin        = 1'b0;
      MARin       = 1'b0;
      MDRin       = 1'b0;
      HIin        = 1'b0;
      LOin        = 1'b0;
      IncPC       = 1'b0;
      Read        = 1'b0;
      Write       = 1'b0;
      op          = 4'd0;
      Mdatain     = 32'd0;
      Gra         = 1'b0;
      Grb         = 1'b0;
      Grc         = 1'b0;
      Rin_dec     = 1'b0;
      Rout_dec    = 1'b0;
      BAout       = 1'b0;
      Cout        = 1'b0;
      CONin       = 1'b0;
      CON_to_PCin = 1'b0;
      OutPortin   = 1'b0;
      InPortout   = 1'b0;
      InPortLoad  = 1'b0;
      InPort_data = 32'd0;
      UseRAM      = 1'b1;
    end
  endtask

  task tick;
    begin
      @(negedge clk);
      @(posedge clk);
      #1;
    end
  endtask

  task check_eq;
    input [31:0] got;
    input [31:0] exp;
    input [255:0] msg;
    begin
      if (got !== exp) begin
        failures = failures + 1;
        $display("FAIL: %0s got=%h exp=%h", msg, got, exp);
      end else begin
        $display("PASS: %0s value=%h", msg, got);
      end
    end
  endtask

  task check_mem;
    input [8:0] addr;
    input [31:0] exp;
    input [255:0] msg;
    begin
      MemDbgAddr = addr;
      #1;
      check_eq(RAM_dbg_data, exp, msg);
    end
  endtask

  task load_reg;
    input integer dst;
    input [31:0] value;
    begin
      clear_ctrl();
      UseRAM = 1'b0;
      Mdatain = value;
      Read = 1'b1;
      MDRin = 1'b1;
      tick;

      clear_ctrl();
      bus_sel = SEL_MDR;
      Rin[dst] = 1'b1;
      tick;
    end
  endtask

  task load_hi;
    input [31:0] value;
    begin
      clear_ctrl();
      UseRAM = 1'b0;
      Mdatain = value;
      Read = 1'b1;
      MDRin = 1'b1;
      tick;

      clear_ctrl();
      bus_sel = SEL_MDR;
      HIin = 1'b1;
      tick;
    end
  endtask

  task load_lo;
    input [31:0] value;
    begin
      clear_ctrl();
      UseRAM = 1'b0;
      Mdatain = value;
      Read = 1'b1;
      MDRin = 1'b1;
      tick;

      clear_ctrl();
      bus_sel = SEL_MDR;
      LOin = 1'b1;
      tick;
    end
  endtask

  task fetch_instr;
    input [31:0] opcode;
    begin
      clear_ctrl();
      UseRAM = 1'b0;
      bus_sel = SEL_PC;
      MARin = 1'b1;
      IncPC = 1'b1;
      Zin = 1'b1;
      tick;

      clear_ctrl();
      UseRAM = 1'b0;
      bus_sel = SEL_ZLOW;
      PCin = 1'b1;
      Read = 1'b1;
      MDRin = 1'b1;
      Mdatain = opcode;
      tick;

      clear_ctrl();
      bus_sel = SEL_MDR;
      IRin = 1'b1;
      tick;

      check_eq(IR_q_dbg, opcode, "fetch opcode into IR");
    end
  endtask

  task set_pc_value;
    input [31:0] value;
    begin
      clear_ctrl();
      UseRAM = 1'b0;
      Mdatain = value;
      Read = 1'b1;
      MDRin = 1'b1;
      tick;

      clear_ctrl();
      bus_sel = SEL_MDR;
      PCin = 1'b1;
      tick;
    end
  endtask

  task exec_ld;
    begin
      clear_ctrl();
      Grb = 1'b1;
      Rout_dec = 1'b1;
      BAout = 1'b1;
      Yin = 1'b1;
      tick;

      clear_ctrl();
      Cout = 1'b1;
      op = `ADDop;
      Zin = 1'b1;
      tick;

      clear_ctrl();
      bus_sel = SEL_ZLOW;
      MARin = 1'b1;
      tick;

      clear_ctrl();
      UseRAM = 1'b1;
      Read = 1'b1;
      MDRin = 1'b1;
      tick;

      clear_ctrl();
      bus_sel = SEL_MDR;
      Gra = 1'b1;
      Rin_dec = 1'b1;
      tick;
    end
  endtask

  task exec_ldi;
    begin
      clear_ctrl();
      Grb = 1'b1;
      Rout_dec = 1'b1;
      BAout = 1'b1;
      Yin = 1'b1;
      tick;

      clear_ctrl();
      Cout = 1'b1;
      op = `ADDop;
      Zin = 1'b1;
      tick;

      clear_ctrl();
      bus_sel = SEL_ZLOW;
      Gra = 1'b1;
      Rin_dec = 1'b1;
      tick;
    end
  endtask

  task exec_st;
    begin
      clear_ctrl();
      Gra = 1'b1;
      Rout_dec = 1'b1;
      MDRin = 1'b1;
      tick;

      clear_ctrl();
      Grb = 1'b1;
      Rout_dec = 1'b1;
      BAout = 1'b1;
      Yin = 1'b1;
      tick;

      clear_ctrl();
      Cout = 1'b1;
      op = `ADDop;
      Zin = 1'b1;
      tick;

      clear_ctrl();
      bus_sel = SEL_ZLOW;
      MARin = 1'b1;
      tick;

      clear_ctrl();
      Write = 1'b1;
      tick;
    end
  endtask

  task exec_imm_alu;
    input [3:0] imm_op;
    begin
      clear_ctrl();
      Grb = 1'b1;
      Rout_dec = 1'b1;
      Yin = 1'b1;
      tick;

      clear_ctrl();
      Cout = 1'b1;
      op = imm_op;
      Zin = 1'b1;
      tick;

      clear_ctrl();
      bus_sel = SEL_ZLOW;
      Gra = 1'b1;
      Rin_dec = 1'b1;
      tick;
    end
  endtask

  task exec_branch;
    begin
      clear_ctrl();
      Gra = 1'b1;
      Rout_dec = 1'b1;
      CONin = 1'b1;
      tick;

      clear_ctrl();
      bus_sel = SEL_PC;
      Yin = 1'b1;
      tick;

      clear_ctrl();
      Cout = 1'b1;
      op = `ADDop;
      Zin = 1'b1;
      tick;

      clear_ctrl();
      bus_sel = SEL_ZLOW;
      CON_to_PCin = 1'b1;
      tick;
    end
  endtask

  task exec_jr;
    begin
      clear_ctrl();
      Gra = 1'b1;
      Rout_dec = 1'b1;
      PCin = 1'b1;
      tick;
    end
  endtask

  task exec_jal;
    begin
      clear_ctrl();
      bus_sel = SEL_PC;
      Rin[12] = 1'b1;
      tick;

      clear_ctrl();
      Gra = 1'b1;
      Rout_dec = 1'b1;
      PCin = 1'b1;
      tick;
    end
  endtask

  task exec_mfhi;
    begin
      clear_ctrl();
      bus_sel = SEL_HI;
      Gra = 1'b1;
      Rin_dec = 1'b1;
      tick;
    end
  endtask

  task exec_mflo;
    begin
      clear_ctrl();
      bus_sel = SEL_LO;
      Gra = 1'b1;
      Rin_dec = 1'b1;
      tick;
    end
  endtask

  task exec_out;
    begin
      clear_ctrl();
      Gra = 1'b1;
      Rout_dec = 1'b1;
      OutPortin = 1'b1;
      tick;
    end
  endtask

  task exec_in;
    input [31:0] input_value;
    begin
      clear_ctrl();
      InPort_data = input_value;
      check_eq(InPort_data, input_value, "in stimulus before load");
      InPortLoad = 1'b1;
      tick;
      check_eq(InPort_q_dbg, input_value, "input port latched");

      clear_ctrl();
      InPortout = 1'b1;
      Gra = 1'b1;
      Rin_dec = 1'b1;
      tick;
    end
  endtask

  initial begin
    $dumpfile("phase2.vcd");
    $dumpvars(0, tb_phase2);

    failures = 0;
    MemDbgAddr = 9'd0;

    PC = 32'd0;
    IR = 32'd0;
    HI = 32'd0;
    LO = 32'd0;
    MAR = 32'd0;
    MDR = 32'd0;

    clear_ctrl();
    reset = 1'b1;
    tick;
    reset = 1'b0;

    // Verify RAM preload values from hex file.
    check_mem(9'h065, 32'h00000084, "init mem[0x65]");
    check_mem(9'h0C9, 32'h0000002B, "init mem[0xC9]");
    check_mem(9'h01F, 32'h000000D4, "init mem[0x1F]");
    check_mem(9'h082, 32'h000000A7, "init mem[0x82]");

    // 3.1 ld/ldi
    load_reg(2, 32'h00000057);
    fetch_instr(mk_ir_imm(`OP_LD, 4'd7, 4'd0, 19'h00065));
    exec_ld();
    check_eq(R7_q, 32'h00000084, "ld R7, 0x65");

    fetch_instr(mk_ir_imm(`OP_LD, 4'd0, 4'd2, 19'h00072));
    exec_ld();
    check_eq(R0_q, 32'h0000002B, "ld R0, 0x72(R2)");

    fetch_instr(mk_ir_imm(`OP_LDI, 4'd7, 4'd0, 19'h00065));
    exec_ldi();
    check_eq(R7_q, 32'h00000065, "ldi R7, 0x65");

    fetch_instr(mk_ir_imm(`OP_LDI, 4'd0, 4'd2, 19'h00072));
    exec_ldi();
    check_eq(R0_q, 32'h000000C9, "ldi R0, 0x72(R2)");

    // 3.2 st
    load_reg(6, 32'h00000063);
    fetch_instr(mk_ir_imm(`OP_ST, 4'd6, 4'd0, 19'h0001F));
    exec_st();
    check_mem(9'h01F, 32'h00000063, "st 0x1F, R6");

    fetch_instr(mk_ir_imm(`OP_ST, 4'd6, 4'd6, 19'h0001F));
    exec_st();
    check_mem(9'h082, 32'h00000063, "st 0x1F(R6), R6");

    // 3.3 addi/andi/ori
    load_reg(4, 32'h00000020);
    fetch_instr(mk_ir_imm(`OP_ADDI, 4'd7, 4'd4, 19'h7FFF7)); // -9
    exec_imm_alu(`ADDop);
    check_eq(R7_q, 32'h00000017, "addi R7, R4, -9");

    load_reg(4, 32'h000000F3);
    fetch_instr(mk_ir_imm(`OP_ANDI, 4'd7, 4'd4, 19'h00071));
    exec_imm_alu(`ANDop);
    check_eq(R7_q, 32'h00000071, "andi R7, R4, 0x71");

    fetch_instr(mk_ir_imm(`OP_ORI, 4'd7, 4'd4, 19'h00071));
    exec_imm_alu(`ORop);
    check_eq(R7_q, 32'h000000F3, "ori R7, R4, 0x71");

    // 3.4 branches (taken + not taken)
    set_pc_value(32'h00000010);
    load_reg(3, 32'h00000000);
    fetch_instr(mk_ir_branch(`OP_BR, 4'd3, 2'b00, 19'd48));
    exec_branch();
    check_eq(PC_q_dbg, 32'h00000041, "brzr taken");

    set_pc_value(32'h00000010);
    load_reg(3, 32'h00000001);
    fetch_instr(mk_ir_branch(`OP_BR, 4'd3, 2'b00, 19'd48));
    exec_branch();
    check_eq(PC_q_dbg, 32'h00000011, "brzr not taken");

    set_pc_value(32'h00000010);
    load_reg(3, 32'h00000001);
    fetch_instr(mk_ir_branch(`OP_BR, 4'd3, 2'b01, 19'd48));
    exec_branch();
    check_eq(PC_q_dbg, 32'h00000041, "brnz taken");

    set_pc_value(32'h00000010);
    load_reg(3, 32'h00000000);
    fetch_instr(mk_ir_branch(`OP_BR, 4'd3, 2'b01, 19'd48));
    exec_branch();
    check_eq(PC_q_dbg, 32'h00000011, "brnz not taken");

    set_pc_value(32'h00000010);
    load_reg(3, 32'h00000005);
    fetch_instr(mk_ir_branch(`OP_BR, 4'd3, 2'b10, 19'd48));
    exec_branch();
    check_eq(PC_q_dbg, 32'h00000041, "brpl taken");

    set_pc_value(32'h00000010);
    load_reg(3, 32'hFFFFFFFF);
    fetch_instr(mk_ir_branch(`OP_BR, 4'd3, 2'b10, 19'd48));
    exec_branch();
    check_eq(PC_q_dbg, 32'h00000011, "brpl not taken");

    set_pc_value(32'h00000010);
    load_reg(3, 32'hFFFFFFFF);
    fetch_instr(mk_ir_branch(`OP_BR, 4'd3, 2'b11, 19'd48));
    exec_branch();
    check_eq(PC_q_dbg, 32'h00000041, "brmi taken");

    set_pc_value(32'h00000010);
    load_reg(3, 32'h00000005);
    fetch_instr(mk_ir_branch(`OP_BR, 4'd3, 2'b11, 19'd48));
    exec_branch();
    check_eq(PC_q_dbg, 32'h00000011, "brmi not taken");

    // 3.5 jr / jal
    set_pc_value(32'h00000010);
    load_reg(12, 32'h000000FF);
    fetch_instr(mk_ir_rrr(`OP_JR, 4'd12, 4'd0, 4'd0));
    exec_jr();
    check_eq(PC_q_dbg, 32'h000000FF, "jr R12");

    set_pc_value(32'h00000020);
    load_reg(4, 32'h000000AA);
    load_reg(12, 32'h00000000);
    fetch_instr(mk_ir_rrr(`OP_JAL, 4'd4, 4'd0, 4'd0));
    exec_jal();
    check_eq(R12_q, 32'h00000021, "jal saved return address in R12");
    check_eq(PC_q_dbg, 32'h000000AA, "jal jump target");

    // 3.6 mfhi / mflo
    load_hi(32'h12345678);
    load_lo(32'h89ABCDEF);
    fetch_instr(mk_ir_rrr(`OP_MFHI, 4'd5, 4'd0, 4'd0));
    exec_mfhi();
    check_eq(R5_q, 32'h12345678, "mfhi R5");

    fetch_instr(mk_ir_rrr(`OP_MFLO, 4'd1, 4'd0, 4'd0));
    exec_mflo();
    check_eq(R1_q, 32'h89ABCDEF, "mflo R1");

    // 3.7 out / in
    load_reg(7, 32'hDEADBEEF);
    fetch_instr(mk_ir_rrr(`OP_OUT, 4'd7, 4'd0, 4'd0));
    exec_out();
    check_eq(OutPort_q_dbg, 32'hDEADBEEF, "out R7");

    fetch_instr(mk_ir_rrr(`OP_IN, 4'd5, 4'd0, 4'd0));
    exec_in(32'hCAFEBABE);
    check_eq(R5_q, 32'hCAFEBABE, "in R5");

    if (failures == 0) begin
      $display("PASS PHASE2 SUITE");
    end else begin
      $display("FAIL PHASE2 SUITE: failures=%0d", failures);
      $fatal;
    end

    $finish;
  end
endmodule
