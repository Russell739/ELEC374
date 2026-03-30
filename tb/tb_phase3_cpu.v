`timescale 1ns/1ps

module tb_phase3_cpu;
  reg clk = 1'b0;
  always #5 clk = ~clk;

  reg         reset;
  reg         stop;
  reg  [31:0] in_port_data;
  reg  [8:0]  mem_dbg_addr;

  wire        run;
  wire [31:0] bus_dbg;
  wire [31:0] ir_dbg;
  wire [31:0] pc_dbg;
  wire [31:0] mar_dbg;
  wire [31:0] mdr_dbg;
  wire [31:0] hi_dbg;
  wire [31:0] lo_dbg;
  wire [31:0] y_dbg;
  wire [63:0] z_dbg;
  wire        con_dbg;
  wire [31:0] out_port_dbg;
  wire [31:0] in_port_dbg;
  wire [31:0] ram_read_data_dbg;
  wire [31:0] ram_dbg_data;
  wire [31:0] r0_dbg;
  wire [31:0] r1_dbg;
  wire [31:0] r2_dbg;
  wire [31:0] r3_dbg;
  wire [31:0] r4_dbg;
  wire [31:0] r5_dbg;
  wire [31:0] r6_dbg;
  wire [31:0] r7_dbg;
  wire [31:0] r8_dbg;
  wire [31:0] r9_dbg;
  wire [31:0] r10_dbg;
  wire [31:0] r11_dbg;
  wire [31:0] r12_dbg;
  wire [31:0] r13_dbg;
  wire [31:0] r14_dbg;
  wire [31:0] r15_dbg;

  localparam [31:0] IR_BRMI            = 32'hAA980003;
  localparam [31:0] IR_BRPL            = 32'hA8900002;
  localparam [31:0] IR_LDI_AFTER_BRMI  = 32'h8AA80005;
  localparam [31:0] IR_SKIP_12         = 32'h89A80007;
  localparam [31:0] IR_SKIP_13         = 32'h8B9FFFFC;
  localparam [31:0] IR_JAL             = 32'h9D000000;
  localparam [31:0] IR_JR              = 32'hA6000000;
  localparam [31:0] IR_HALT            = 32'hD8000000;

  integer failures;
  integer cycles;

  reg seen_brmi;
  reg seen_brpl;
  reg seen_after_brmi;
  reg seen_skip_12;
  reg seen_skip_13;
  reg seen_jal;
  reg seen_jr;
  reg seen_jal_effect;

  cpu_phase3 #(
    .MEM_INIT_FILE("tb/phase3_mem_init.hex")
  ) dut (
    .clk(clk),
    .reset(reset),
    .stop(stop),
    .in_port_data(in_port_data),
    .mem_dbg_addr(mem_dbg_addr),
    .run(run),
    .bus_dbg(bus_dbg),
    .ir_dbg(ir_dbg),
    .pc_dbg(pc_dbg),
    .mar_dbg(mar_dbg),
    .mdr_dbg(mdr_dbg),
    .hi_dbg(hi_dbg),
    .lo_dbg(lo_dbg),
    .y_dbg(y_dbg),
    .z_dbg(z_dbg),
    .con_dbg(con_dbg),
    .out_port_dbg(out_port_dbg),
    .in_port_dbg(in_port_dbg),
    .ram_read_data_dbg(ram_read_data_dbg),
    .ram_dbg_data(ram_dbg_data),
    .r0_dbg(r0_dbg),
    .r1_dbg(r1_dbg),
    .r2_dbg(r2_dbg),
    .r3_dbg(r3_dbg),
    .r4_dbg(r4_dbg),
    .r5_dbg(r5_dbg),
    .r6_dbg(r6_dbg),
    .r7_dbg(r7_dbg),
    .r8_dbg(r8_dbg),
    .r9_dbg(r9_dbg),
    .r10_dbg(r10_dbg),
    .r11_dbg(r11_dbg),
    .r12_dbg(r12_dbg),
    .r13_dbg(r13_dbg),
    .r14_dbg(r14_dbg),
    .r15_dbg(r15_dbg)
  );

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
      mem_dbg_addr = addr;
      #1;
      check_eq(ram_dbg_data, exp, msg);
    end
  endtask

  always @(posedge clk) begin
    if (!reset) begin
      if (ir_dbg == IR_BRMI) begin
        seen_brmi <= 1'b1;
      end
      if (ir_dbg == IR_BRPL) begin
        seen_brpl <= 1'b1;
      end
      if (ir_dbg == IR_LDI_AFTER_BRMI) begin
        seen_after_brmi <= 1'b1;
      end
      if (ir_dbg == IR_SKIP_12) begin
        seen_skip_12 <= 1'b1;
      end
      if (ir_dbg == IR_SKIP_13) begin
        seen_skip_13 <= 1'b1;
      end
      if (ir_dbg == IR_JAL) begin
        seen_jal <= 1'b1;
      end
      if (ir_dbg == IR_JR) begin
        seen_jr <= 1'b1;
      end
      if ((r12_dbg == 32'h00000029) && (pc_dbg == 32'h000000B2)) begin
        seen_jal_effect <= 1'b1;
      end
    end
  end

  initial begin
    $dumpfile("phase3_cpu.vcd");
    $dumpvars(0, tb_phase3_cpu);

    failures = 0;
    cycles = 0;

    seen_brmi = 1'b0;
    seen_brpl = 1'b0;
    seen_after_brmi = 1'b0;
    seen_skip_12 = 1'b0;
    seen_skip_13 = 1'b0;
    seen_jal = 1'b0;
    seen_jr = 1'b0;
    seen_jal_effect = 1'b0;

    stop = 1'b0;
    in_port_data = 32'b0;
    mem_dbg_addr = 9'd0;

    reset = 1'b1;
    @(posedge clk);
    @(posedge clk);
    reset = 1'b0;

    while (run && (cycles < 5000)) begin
      @(posedge clk);
      cycles = cycles + 1;
    end

    if (run) begin
      failures = failures + 1;
      $display("FAIL: timeout waiting for halt");
    end else begin
      $display("PASS: halted in %0d cycles", cycles);
    end

    // Final architectural state checks.
    check_eq(ir_dbg, IR_HALT, "halt IR latched");
    check_eq(r0_dbg, 32'h00000614, "R0 final");
    check_eq(r1_dbg, 32'h00000000, "R1 final");
    check_eq(r2_dbg, 32'h00000004, "R2 final");
    check_eq(r3_dbg, 32'h00000019, "R3 final");
    check_eq(r4_dbg, 32'h00006800, "R4 final");
    check_eq(r5_dbg, 32'h00000680, "R5 final");
    check_eq(r6_dbg, 32'h000000AF, "R6 final");
    check_eq(r7_dbg, 32'h00000007, "R7 final");
    check_eq(r8_dbg, 32'h00000009, "R8 final");
    check_eq(r9_dbg, 32'h00000015, "R9 final");
    check_eq(r10_dbg, 32'h000000B2, "R10 final");
    check_eq(r11_dbg, 32'h00000005, "R11 final");
    check_eq(r12_dbg, 32'h00000029, "R12 return address");
    check_eq(r13_dbg, 32'h00000010, "R13 final");
    check_eq(r14_dbg, 32'h000000AB, "R14 final");
    check_eq(r15_dbg, 32'h00000000, "R15 final");
    check_eq(hi_dbg, 32'h00000004, "HI final");
    check_eq(lo_dbg, 32'h00000003, "LO final");

    check_mem(9'h0A3, 32'h00000008, "mem[0xA3] final");
    check_mem(9'h089, 32'h0000006C, "mem[0x89] final");

    // Control-flow evidence checks.
    if (!seen_brmi) begin
      failures = failures + 1;
      $display("FAIL: brmi instruction was not observed");
    end else begin
      $display("PASS: brmi observed");
    end

    if (!seen_after_brmi) begin
      failures = failures + 1;
      $display("FAIL: brmi not-taken path evidence missing (next instruction not observed)");
    end else begin
      $display("PASS: brmi not-taken path observed");
    end

    if (!seen_brpl) begin
      failures = failures + 1;
      $display("FAIL: brpl instruction was not observed");
    end else begin
      $display("PASS: brpl observed");
    end

    if (seen_skip_12 || seen_skip_13) begin
      failures = failures + 1;
      $display("FAIL: brpl-taken path violated (skipped instructions executed)");
    end else begin
      $display("PASS: brpl taken path observed (skipped instructions not executed)");
    end

    if (!seen_jal || !seen_jal_effect || !seen_jr) begin
      failures = failures + 1;
      $display("FAIL: jal/jr control-flow evidence missing jal=%0d jal_effect=%0d jr=%0d",
               seen_jal, seen_jal_effect, seen_jr);
    end else begin
      $display("PASS: jal/jr control-flow observed");
    end

    if (failures == 0) begin
      $display("PASS PHASE3 CPU SUITE");
    end else begin
      $display("FAIL PHASE3 CPU SUITE: failures=%0d", failures);
      $fatal;
    end

    $finish;
  end

endmodule
