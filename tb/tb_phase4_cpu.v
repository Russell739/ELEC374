`timescale 1ns/1ps

module tb_phase4_cpu;
  reg clk = 1'b0;
  always #5 clk = ~clk;

  reg         reset;
  reg         stop;
  reg  [31:0] in_port_data;
  reg  [8:0]  mem_dbg_addr;

  wire        run;
  wire [31:0] ir_dbg;
  wire [31:0] hi_dbg;
  wire [31:0] lo_dbg;
  wire [31:0] out_port_dbg;
  wire [31:0] ram_dbg_data;
  wire [31:0] r2_dbg;
  wire [31:0] r3_dbg;
  wire [31:0] r5_dbg;
  wire [31:0] r6_dbg;
  wire [31:0] r7_dbg;
  wire [31:0] r12_dbg;

  integer failures;
  integer cycles;
  integer out_count;
  integer i;

  reg [31:0] last_out;
  reg [31:0] expected_out [0:40];

  cpu_phase3 #(
    .MEM_INIT_FILE("tb/phase4_mem_init.hex")
  ) dut (
    .clk(clk),
    .reset(reset),
    .stop(stop),
    .in_port_data(in_port_data),
    .mem_dbg_addr(mem_dbg_addr),
    .run(run),
    .bus_dbg(),
    .ir_dbg(ir_dbg),
    .pc_dbg(),
    .mar_dbg(),
    .mdr_dbg(),
    .hi_dbg(hi_dbg),
    .lo_dbg(lo_dbg),
    .y_dbg(),
    .z_dbg(),
    .con_dbg(),
    .out_port_dbg(out_port_dbg),
    .in_port_dbg(),
    .ram_read_data_dbg(),
    .ram_dbg_data(ram_dbg_data),
    .r0_dbg(),
    .r1_dbg(),
    .r2_dbg(r2_dbg),
    .r3_dbg(r3_dbg),
    .r4_dbg(),
    .r5_dbg(r5_dbg),
    .r6_dbg(r6_dbg),
    .r7_dbg(r7_dbg),
    .r8_dbg(),
    .r9_dbg(),
    .r10_dbg(),
    .r11_dbg(),
    .r12_dbg(r12_dbg),
    .r13_dbg(),
    .r14_dbg(),
    .r15_dbg()
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

  initial begin
    for (i = 0; i < 5; i = i + 1) begin
      expected_out[(i * 8) + 0] = 32'h000000E0;
      expected_out[(i * 8) + 1] = 32'h00000070;
      expected_out[(i * 8) + 2] = 32'h00000038;
      expected_out[(i * 8) + 3] = 32'h0000001C;
      expected_out[(i * 8) + 4] = 32'h0000000E;
      expected_out[(i * 8) + 5] = 32'h00000007;
      expected_out[(i * 8) + 6] = 32'h00000003;
      expected_out[(i * 8) + 7] = 32'h00000001;
    end
    expected_out[40] = 32'h00000063;

    failures = 0;
    cycles = 0;
    out_count = 0;
    last_out = 32'b0;

    stop = 1'b0;
    in_port_data = 32'h000000E0;
    mem_dbg_addr = 9'd0;

    reset = 1'b1;
    @(posedge clk);
    @(posedge clk);
    reset = 1'b0;

    // Keep the board image exact, but shrink the delay loop for regression speed.
    dut.UDATAPATH.URAM.mem[9'h088] = 32'h00000004;

    while (run && (cycles < 50000)) begin
      @(posedge clk);
      #1;
      cycles = cycles + 1;

      if (out_port_dbg !== last_out) begin
        if (out_count > 40) begin
          failures = failures + 1;
          $display("FAIL: unexpected extra output value=%h at index=%0d", out_port_dbg, out_count);
        end else if (out_port_dbg !== expected_out[out_count]) begin
          failures = failures + 1;
          $display("FAIL: output[%0d] got=%h exp=%h", out_count, out_port_dbg, expected_out[out_count]);
        end else begin
          $display("PASS: output[%0d] value=%h", out_count, out_port_dbg);
        end

        last_out = out_port_dbg;
        out_count = out_count + 1;
      end
    end

    if (run) begin
      failures = failures + 1;
      $display("FAIL: timeout waiting for halt");
    end else begin
      $display("PASS: halted in %0d cycles", cycles);
    end

    if (out_count !== 41) begin
      failures = failures + 1;
      $display("FAIL: expected 41 output updates, observed %0d", out_count);
    end else begin
      $display("PASS: observed all 41 output updates");
    end

    check_eq(ir_dbg, 32'hD8000000, "halt IR latched");
    check_eq(r2_dbg, 32'h00000000, "R2 loop counter exhausted");
    check_eq(r3_dbg, 32'h0000002E, "R3 loop address");
    check_eq(r5_dbg, 32'h00000001, "R5 shift amount");
    check_eq(r6_dbg, 32'h00000063, "R6 final display value");
    check_eq(r7_dbg, 32'h00000000, "R7 delay counter drained");
    check_eq(r12_dbg, 32'h00000029, "R12 preserved return address");
    check_eq(hi_dbg, 32'h00000004, "HI final");
    check_eq(lo_dbg, 32'h00000003, "LO final");
    check_eq(out_port_dbg, 32'h00000063, "output port final");

    check_mem(9'h077, 32'h000000E0, "mem[0x77] saved input");
    check_mem(9'h089, 32'h0000006C, "mem[0x89] final");
    check_mem(9'h0A3, 32'h00000008, "mem[0xA3] final");

    if (failures == 0) begin
      $display("PASS PHASE4 CPU SUITE");
    end else begin
      $display("FAIL PHASE4 CPU SUITE: failures=%0d", failures);
      $fatal;
    end

    $finish;
  end
endmodule
