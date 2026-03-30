module cpu_phase3 #(
    parameter MEM_INIT_FILE = ""
) (
    input  wire        clk,
    input  wire        reset,
    input  wire        stop,
    input  wire [31:0] in_port_data,
    input  wire [8:0]  mem_dbg_addr,

    output wire        run,
    output wire [31:0] bus_dbg,
    output wire [31:0] ir_dbg,
    output wire [31:0] pc_dbg,
    output wire [31:0] mar_dbg,
    output wire [31:0] mdr_dbg,
    output wire [31:0] hi_dbg,
    output wire [31:0] lo_dbg,
    output wire [31:0] y_dbg,
    output wire [63:0] z_dbg,
    output wire        con_dbg,
    output wire [31:0] out_port_dbg,
    output wire [31:0] in_port_dbg,
    output wire [31:0] ram_read_data_dbg,
    output wire [31:0] ram_dbg_data,
    output wire [31:0] r0_dbg,
    output wire [31:0] r1_dbg,
    output wire [31:0] r2_dbg,
    output wire [31:0] r3_dbg,
    output wire [31:0] r4_dbg,
    output wire [31:0] r5_dbg,
    output wire [31:0] r6_dbg,
    output wire [31:0] r7_dbg,
    output wire [31:0] r8_dbg,
    output wire [31:0] r9_dbg,
    output wire [31:0] r10_dbg,
    output wire [31:0] r11_dbg,
    output wire [31:0] r12_dbg,
    output wire [31:0] r13_dbg,
    output wire [31:0] r14_dbg,
    output wire [31:0] r15_dbg
);

    wire [4:0]  bus_sel;
    wire [15:0] Rin;
    wire        Yin;
    wire        Zin;
    wire        PCin;
    wire        IRin;
    wire        MARin;
    wire        MDRin;
    wire        HIin;
    wire        LOin;
    wire        IncPC;
    wire        Read;
    wire        Write;
    wire        Gra;
    wire        Grb;
    wire        Grc;
    wire        Rin_dec;
    wire        Rout_dec;
    wire        BAout;
    wire        Cout;
    wire        CONin;
    wire        CON_to_PCin;
    wire        OutPortin;
    wire        InPortout;
    wire        InPortLoad;
    wire [3:0]  op;

    control_unit UCTRL (
        .clk(clk),
        .reset(reset),
        .stop(stop),
        .IR(ir_dbg),
        .CON_q(con_dbg),
        .Run(run),
        .bus_sel(bus_sel),
        .Rin(Rin),
        .Yin(Yin),
        .Zin(Zin),
        .PCin(PCin),
        .IRin(IRin),
        .MARin(MARin),
        .MDRin(MDRin),
        .HIin(HIin),
        .LOin(LOin),
        .IncPC(IncPC),
        .Read(Read),
        .Write(Write),
        .Gra(Gra),
        .Grb(Grb),
        .Grc(Grc),
        .Rin_dec(Rin_dec),
        .Rout_dec(Rout_dec),
        .BAout(BAout),
        .Cout(Cout),
        .CONin(CONin),
        .CON_to_PCin(CON_to_PCin),
        .OutPortin(OutPortin),
        .InPortout(InPortout),
        .InPortLoad(InPortLoad),
        .op(op)
    );

    datapath_logic #(
        .MEM_INIT_FILE(MEM_INIT_FILE)
    ) UDATAPATH (
        .clk(clk),
        .reset(reset),

        .bus_sel(bus_sel),
        .Rin(Rin),
        .Yin(Yin),
        .Zin(Zin),

        .PCin(PCin),
        .IRin(IRin),
        .MARin(MARin),
        .MDRin(MDRin),
        .HIin(HIin),
        .LOin(LOin),
        .IncPC(IncPC),
        .Read(Read),
        .Write(Write),
        .Mdatain(32'b0),

        .Gra(Gra),
        .Grb(Grb),
        .Grc(Grc),
        .Rin_dec(Rin_dec),
        .Rout_dec(Rout_dec),
        .BAout(BAout),
        .Cout(Cout),
        .CONin(CONin),
        .CON_to_PCin(CON_to_PCin),
        .OutPortin(OutPortin),
        .InPortout(InPortout),
        .InPortLoad(InPortLoad),
        .InPort_data(in_port_data),
        .UseRAM(1'b1),
        .MemDbgAddr(mem_dbg_addr),

        .PC(32'b0),
        .IR(32'b0),
        .HI(32'b0),
        .LO(32'b0),
        .MAR(32'b0),
        .MDR(32'b0),

        .op(op),

        .BUS(bus_dbg),
        .R0_q(r0_dbg),
        .R1_q(r1_dbg),
        .R2_q(r2_dbg),
        .R3_q(r3_dbg),
        .R4_q(r4_dbg),
        .R5_q(r5_dbg),
        .R6_q(r6_dbg),
        .R7_q(r7_dbg),
        .R8_q(r8_dbg),
        .R9_q(r9_dbg),
        .R10_q(r10_dbg),
        .R11_q(r11_dbg),
        .R12_q(r12_dbg),
        .R13_q(r13_dbg),
        .R14_q(r14_dbg),
        .R15_q(r15_dbg),
        .HI_q_dbg(hi_dbg),
        .LO_q_dbg(lo_dbg),
        .IR_q_dbg(ir_dbg),
        .PC_q_dbg(pc_dbg),
        .MAR_q_dbg(mar_dbg),
        .MDR_q_dbg(mdr_dbg),
        .Y_q(y_dbg),
        .Z_q(z_dbg),
        .CON_q_dbg(con_dbg),
        .OutPort_q_dbg(out_port_dbg),
        .InPort_q_dbg(in_port_dbg),
        .RAM_read_data_dbg(ram_read_data_dbg),
        .RAM_dbg_data(ram_dbg_data)
    );

endmodule
