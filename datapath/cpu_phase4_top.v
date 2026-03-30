module cpu_phase4_top (
    input  wire        CLOCK_50,
    input  wire [1:0]  KEY,
    input  wire [7:0]  SW,
    output wire        RUN_LED,
    output wire [6:0]  HEX0,
    output wire [6:0]  HEX1,
    output wire [6:0]  HEX2,
    output wire [6:0]  HEX3,
    output wire [6:0]  HEX4,
    output wire [6:0]  HEX5
);
    localparam USE_RAW_CLOCK = 1'b0;
    localparam integer CLOCK_DIVIDER_BIT = 2; // 50 MHz / 2^(2+1) = 6.25 MHz

    reg [31:0] clock_divider = 32'b0;
    wire       cpu_clk;
    wire       reset;
    wire       stop;
    wire       run;
    wire [31:0] out_port_dbg;

    always @(posedge CLOCK_50) begin
        clock_divider <= clock_divider + 32'd1;
    end

    assign cpu_clk = USE_RAW_CLOCK ? CLOCK_50 : clock_divider[CLOCK_DIVIDER_BIT];
    assign reset   = ~KEY[0];
    assign stop    = ~KEY[1];
    assign RUN_LED = run;

    seven_seg_hex u_hex0 (
        .hex(out_port_dbg[3:0]),
        .seg_n(HEX0)
    );

    seven_seg_hex u_hex1 (
        .hex(out_port_dbg[7:4]),
        .seg_n(HEX1)
    );

    assign HEX2 = 7'b1111111;
    assign HEX3 = 7'b1111111;
    assign HEX4 = 7'b1111111;
    assign HEX5 = 7'b1111111;

    cpu_phase3 #(
        .MEM_INIT_FILE("tb/phase4_mem_init.hex")
    ) dut (
        .clk(cpu_clk),
        .reset(reset),
        .stop(stop),
        .in_port_data({24'b0, SW}),
        .mem_dbg_addr(9'd0),
        .run(run),
        .bus_dbg(),
        .ir_dbg(),
        .pc_dbg(),
        .mar_dbg(),
        .mdr_dbg(),
        .hi_dbg(),
        .lo_dbg(),
        .y_dbg(),
        .z_dbg(),
        .con_dbg(),
        .out_port_dbg(out_port_dbg),
        .in_port_dbg(),
        .ram_read_data_dbg(),
        .ram_dbg_data(),
        .r0_dbg(),
        .r1_dbg(),
        .r2_dbg(),
        .r3_dbg(),
        .r4_dbg(),
        .r5_dbg(),
        .r6_dbg(),
        .r7_dbg(),
        .r8_dbg(),
        .r9_dbg(),
        .r10_dbg(),
        .r11_dbg(),
        .r12_dbg(),
        .r13_dbg(),
        .r14_dbg(),
        .r15_dbg()
    );
endmodule
