module datapath_logic #(
    parameter MEM_INIT_FILE = ""
) (
    input   wire        clk,
    input   wire        reset,

    // bus control
    input   wire [4:0]  bus_sel,
    input   wire [15:0] Rin,
    input   wire        Yin,
    input   wire        Zin,

    // control of internal special registers
    input   wire        PCin,
    input   wire        IRin,
    input   wire        MARin,
    input   wire        MDRin,
    input   wire        HIin,
    input   wire        LOin,
    input   wire        IncPC,
    input   wire        Read,
    input   wire        Write,
    input   wire [31:0] Mdatain,

    // phase 2 controls
    input   wire        Gra,
    input   wire        Grb,
    input   wire        Grc,
    input   wire        Rin_dec,
    input   wire        Rout_dec,
    input   wire        BAout,
    input   wire        Cout,
    input   wire        CONin,
    input   wire        CON_to_PCin,
    input   wire        OutPortin,
    input   wire        InPortout,
    input   wire        InPortLoad,
    input   wire [31:0] InPort_data,
    input   wire        UseRAM,
    input   wire [8:0]  MemDbgAddr,

    // reset-time seed values for internal special registers
    input   wire [31:0] PC,
    input   wire [31:0] IR,
    input   wire [31:0] HI,
    input   wire [31:0] LO,
    input   wire [31:0] MAR,
    input   wire [31:0] MDR,

    // ALU logic controls
    input   wire [3:0]  op,

    // debug/visibility
    output  wire [31:0] BUS,
    output  wire [31:0] R5_q,
    output  wire [31:0] R6_q,
    output  wire [31:0] R3_q,
    output  wire [31:0] R2_q,
    output  wire [31:0] R0_q,
    output  wire [31:0] R1_q,
    output  wire [31:0] R4_q,
    output  wire [31:0] R12_q,
    output  wire [31:0] R7_q,
    output  wire [31:0] HI_q_dbg,
    output  wire [31:0] LO_q_dbg,
    output  wire [31:0] IR_q_dbg,
    output  wire [31:0] PC_q_dbg,
    output  wire [31:0] Y_q,
    output  wire [63:0] Z_q,

    // phase 2 debug
    output  wire        CON_q_dbg,
    output  wire [31:0] OutPort_q_dbg,
    output  wire [31:0] InPort_q_dbg,
    output  wire [31:0] RAM_read_data_dbg,
    output  wire [31:0] RAM_dbg_data
);

    // -------- Registers R0..R15 --------
    wire [31:0] R [0:15];
    wire [15:0] Rin_decoded;
    wire [15:0] Rout_decoded;
    wire [3:0]  decoded_reg_idx;
    wire [15:0] Rin_effective;

    assign Rin_effective = Rin | Rin_decoded;

    genvar i;
    generate
      for (i = 0; i < 16; i = i + 1) begin : GEN_REGS
        register32 Ri (
          .clk(clk), .reset(reset),
          .en(Rin_effective[i]),
          .d(BUS),
          .q(R[i])
        );
      end
    endgenerate

    assign R5_q = R[5];
    assign R6_q = R[6];
    assign R2_q = R[2];
    assign R3_q = R[3];
    assign R0_q = R[0];
    assign R1_q = R[1];
    assign R4_q = R[4];
    assign R12_q = R[12];
    assign R7_q = R[7];

    // -------- Internal special registers --------
    reg [31:0] PC_q;
    reg [31:0] IR_q;
    reg [31:0] MAR_q;
    reg [31:0] MDR_q;
    reg [31:0] HI_q;
    reg [31:0] LO_q;
    reg [31:0] decoded_rout_data;

    wire [31:0] C_sign_extended;
    wire        CON_q;
    wire [31:0] out_port_q;
    wire [31:0] in_port_q;
    wire [31:0] ram_read_data;
    wire [31:0] bus_mux_out;
    wire        decoded_rout_active = |Rout_decoded;
    wire        use_ram_data = (UseRAM === 1'b1);
    wire        write_mem = (Write === 1'b1);
    wire        cout_en = (Cout === 1'b1);
    wire        inportout_en = (InPortout === 1'b1);

    // -------- Y register (operand A latch) --------
    register32 Yreg (
      .clk(clk), .reset(reset),
      .en(Yin),
      .d(BUS),
      .q(Y_q)
    );

    // -------- ALU logic (A=Y, B=BUS) --------
    wire [63:0] ALU_C;

    alu_logic ULOGIC (
      .A(Y_q),
      .B(BUS),
      .op(op),
      .overflow(),
      .C(ALU_C)
    );

    // IncPC path for T0: Z <- PC + 1 when IncPC is asserted.
    wire [63:0] Z_d = IncPC ? {32'b0, (BUS + 32'd1)} : ALU_C;

    // -------- Z register --------
    register64 Zreg (
      .clk(clk), .reset(reset),
      .en(Zin),
      .d(Z_d),
      .q(Z_q)
    );

    wire [31:0] Zlow  = Z_q[31:0];
    wire [31:0] Zhigh = Z_q[63:32];

    assign HI_q_dbg = HI_q;
    assign LO_q_dbg = LO_q;
    assign IR_q_dbg = IR_q;
    assign PC_q_dbg = PC_q;
    assign CON_q_dbg = CON_q;
    assign OutPort_q_dbg = out_port_q;
    assign InPort_q_dbg = in_port_q;
    assign RAM_read_data_dbg = ram_read_data;

    select_encode USELECT (
      .IR(IR_q),
      .Gra(Gra),
      .Grb(Grb),
      .Grc(Grc),
      .Rin_sel(Rin_dec),
      .Rout_sel(Rout_dec),
      .Rin_decoded(Rin_decoded),
      .Rout_decoded(Rout_decoded),
      .selected_reg(decoded_reg_idx)
    );

    sign_extend_c USEXT (
      .IR(IR_q),
      .Cout(Cout),
      .C_sign_extended(C_sign_extended)
    );

    con_ff_logic UCON (
      .clk(clk),
      .reset(reset),
      .CONin(CONin),
      .bus_value(BUS),
      .c2(IR_q[20:19]),
      .CON_q(CON_q)
    );

    io_ports UIO (
      .clk(clk),
      .reset(reset),
      .OutPortin(OutPortin),
      .bus_in(BUS),
      .InPortLoad(InPortLoad),
      .InPort_data(InPort_data),
      .OutPort_q(out_port_q),
      .InPort_q(in_port_q)
    );

    ram512x32 #(
      .MEM_INIT_FILE(MEM_INIT_FILE)
    ) URAM (
      .clk(clk),
      .write_en(write_mem),
      .addr(MAR_q[8:0]),
      .write_data(MDR_q),
      .read_data(ram_read_data),
      .dbg_addr(MemDbgAddr),
      .dbg_data(RAM_dbg_data)
    );

    always @(*) begin
      case (decoded_reg_idx)
        4'd0:  decoded_rout_data = R[0];
        4'd1:  decoded_rout_data = R[1];
        4'd2:  decoded_rout_data = R[2];
        4'd3:  decoded_rout_data = R[3];
        4'd4:  decoded_rout_data = R[4];
        4'd5:  decoded_rout_data = R[5];
        4'd6:  decoded_rout_data = R[6];
        4'd7:  decoded_rout_data = R[7];
        4'd8:  decoded_rout_data = R[8];
        4'd9:  decoded_rout_data = R[9];
        4'd10: decoded_rout_data = R[10];
        4'd11: decoded_rout_data = R[11];
        4'd12: decoded_rout_data = R[12];
        4'd13: decoded_rout_data = R[13];
        4'd14: decoded_rout_data = R[14];
        4'd15: decoded_rout_data = R[15];
        default: decoded_rout_data = 32'b0;
      endcase
    end

    wire [31:0] decoded_bus_value = (BAout && (decoded_reg_idx == 4'd0)) ? 32'b0 : decoded_rout_data;

    assign BUS = decoded_rout_active ? decoded_bus_value :
                 (cout_en ? C_sign_extended :
                 (inportout_en ? in_port_q : bus_mux_out));

    // Special registers load from control signals.
    always @(posedge clk) begin
      if (reset) begin
        PC_q  <= PC;
        IR_q  <= IR;
        MAR_q <= MAR;
        MDR_q <= MDR;
        HI_q  <= HI;
        LO_q  <= LO;
      end else begin
        if (MARin) begin
          MAR_q <= BUS;
        end

        if (MDRin) begin
          MDR_q <= Read ? (use_ram_data ? ram_read_data : Mdatain) : BUS;
        end

        if (IRin) begin
          IR_q <= BUS;
        end

        if (PCin || ((CON_to_PCin === 1'b1) && CON_q)) begin
          PC_q <= BUS;
        end

        if (HIin) begin
          HI_q <= BUS;
        end

        if (LOin) begin
          LO_q <= BUS;
        end
      end
    end

    bus_mux UBUS (
      .sel(bus_sel),

      .R0(R[0]), .R1(R[1]), .R2(R[2]), .R3(R[3]),
      .R4(R[4]), .R5(R[5]), .R6(R[6]), .R7(R[7]),
      .R8(R[8]), .R9(R[9]), .R10(R[10]), .R11(R[11]),
      .R12(R[12]), .R13(R[13]), .R14(R[14]), .R15(R[15]),

      .PC(PC_q),
      .IR(IR_q),
      .Y(Y_q),
      .MAR(MAR_q),
      .MDR(MDR_q),
      .HI(HI_q),
      .LO(LO_q),

      .Zlow(Zlow),
      .Zhigh(Zhigh),

      .bus(bus_mux_out)
    );

endmodule
