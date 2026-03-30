`include "defines.vh"

module control_unit (
    input  wire        clk,
    input  wire        reset,
    input  wire        stop,
    input  wire [31:0] IR,
    input  wire        CON_q,

    output wire        Run,

    output reg  [4:0]  bus_sel,
    output reg  [15:0] Rin,
    output reg         Yin,
    output reg         Zin,
    output reg         PCin,
    output reg         IRin,
    output reg         MARin,
    output reg         MDRin,
    output reg         HIin,
    output reg         LOin,
    output reg         IncPC,
    output reg         Read,
    output reg         Write,

    output reg         Gra,
    output reg         Grb,
    output reg         Grc,
    output reg         Rin_dec,
    output reg         Rout_dec,
    output reg         BAout,
    output reg         Cout,
    output reg         CONin,
    output reg         CON_to_PCin,
    output reg         OutPortin,
    output reg         InPortout,
    output reg         InPortLoad,

    output reg  [3:0]  op
);

    localparam [4:0] SEL_PC    = 5'd16;
    localparam [4:0] SEL_MDR   = 5'd20;
    localparam [4:0] SEL_HI    = 5'd21;
    localparam [4:0] SEL_LO    = 5'd22;
    localparam [4:0] SEL_ZLOW  = 5'd23;
    localparam [4:0] SEL_ZHIGH = 5'd24;

    localparam [5:0]
        S_RESET      = 6'd0,
        S_FETCH0     = 6'd1,
        S_FETCH1     = 6'd2,
        S_FETCH2     = 6'd3,
        S_DECODE     = 6'd42,
        S_ALU_T3     = 6'd4,
        S_ALU_T4     = 6'd5,
        S_ALU_T5     = 6'd6,
        S_UNARY_T3   = 6'd7,
        S_UNARY_T4   = 6'd8,
        S_MD_T3      = 6'd9,
        S_MD_T4      = 6'd10,
        S_MD_T5      = 6'd11,
        S_MD_T6      = 6'd12,
        S_LD_T3      = 6'd13,
        S_LD_T4      = 6'd14,
        S_LD_T5      = 6'd15,
        S_LD_T6      = 6'd16,
        S_LD_T7      = 6'd17,
        S_LDI_T3     = 6'd18,
        S_LDI_T4     = 6'd19,
        S_LDI_T5     = 6'd20,
        S_ST_T3      = 6'd21,
        S_ST_T4      = 6'd22,
        S_ST_T5      = 6'd23,
        S_ST_T6      = 6'd24,
        S_ST_T7      = 6'd25,
        S_IMM_T3     = 6'd26,
        S_IMM_T4     = 6'd27,
        S_IMM_T5     = 6'd28,
        S_BR_T3      = 6'd29,
        S_BR_T4      = 6'd30,
        S_BR_T5      = 6'd31,
        S_BR_T6      = 6'd32,
        S_JR_T3      = 6'd33,
        S_JAL_T3     = 6'd34,
        S_JAL_T4     = 6'd35,
        S_MFHILO_T3  = 6'd36,
        S_OUT_T3     = 6'd37,
        S_IN_T3      = 6'd38,
        S_IN_T4      = 6'd39,
        S_NOP_T3     = 6'd40,
        S_HALT       = 6'd41;

    reg [5:0] state;
    reg [5:0] next_state;
    reg       run_q;
    reg       next_run;

    wire [4:0] opcode = IR[31:27];

    assign Run = run_q;

    function [3:0] alu_from_opcode;
        input [4:0] opcode_f;
        begin
            case (opcode_f)
                `OP_ADD:  alu_from_opcode = `ADDop;
                `OP_SUB:  alu_from_opcode = `SUBop;
                `OP_AND:  alu_from_opcode = `ANDop;
                `OP_OR:   alu_from_opcode = `ORop;
                `OP_SHR:  alu_from_opcode = `SHRop;
                `OP_SHRA: alu_from_opcode = `SHRAop;
                `OP_SHL:  alu_from_opcode = `SHLop;
                `OP_ROR:  alu_from_opcode = `RORop;
                `OP_ROL:  alu_from_opcode = `ROLop;
                `OP_ADDI: alu_from_opcode = `ADDop;
                `OP_ANDI: alu_from_opcode = `ANDop;
                `OP_ORI:  alu_from_opcode = `ORop;
                `OP_MUL:  alu_from_opcode = `MULop;
                `OP_DIV:  alu_from_opcode = `DIVop;
                `OP_NEG:  alu_from_opcode = `NEGop;
                `OP_NOT:  alu_from_opcode = `NOTop;
                default:  alu_from_opcode = 4'd0;
            endcase
        end
    endfunction

    always @(posedge clk) begin
        if (reset) begin
            state  <= S_RESET;
            run_q  <= 1'b1;
        end else begin
            state  <= next_state;
            run_q  <= next_run;
        end
    end

    always @(*) begin
        next_state = state;
        next_run   = run_q;

        bus_sel     = 5'd0;
        Rin         = 16'd0;
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
        op          = 4'd0;

        if (stop) begin
            next_state = S_HALT;
            next_run   = 1'b0;
        end else begin
            case (state)
                S_RESET: begin
                    next_state = S_FETCH0;
                    next_run   = 1'b1;
                end

                S_FETCH0: begin
                    bus_sel   = SEL_PC;
                    MARin     = 1'b1;
                    IncPC     = 1'b1;
                    Zin       = 1'b1;
                    next_state = S_FETCH1;
                end

                S_FETCH1: begin
                    bus_sel   = SEL_ZLOW;
                    PCin      = 1'b1;
                    Read      = 1'b1;
                    MDRin     = 1'b1;
                    next_state = S_FETCH2;
                end

                S_FETCH2: begin
                    bus_sel   = SEL_MDR;
                    IRin      = 1'b1;
                    next_state = S_DECODE;
                end

                S_DECODE: begin
                    case (opcode)
                        `OP_ADD,
                        `OP_SUB,
                        `OP_AND,
                        `OP_OR,
                        `OP_SHR,
                        `OP_SHRA,
                        `OP_SHL,
                        `OP_ROR,
                        `OP_ROL:  next_state = S_ALU_T3;

                        `OP_NEG,
                        `OP_NOT:  next_state = S_UNARY_T3;

                        `OP_MUL,
                        `OP_DIV:  next_state = S_MD_T3;

                        `OP_LD:   next_state = S_LD_T3;
                        `OP_LDI:  next_state = S_LDI_T3;
                        `OP_ST:   next_state = S_ST_T3;

                        `OP_ADDI,
                        `OP_ANDI,
                        `OP_ORI:  next_state = S_IMM_T3;

                        `OP_BR:   next_state = S_BR_T3;
                        `OP_JR:   next_state = S_JR_T3;
                        `OP_JAL:  next_state = S_JAL_T3;

                        `OP_MFHI,
                        `OP_MFLO: next_state = S_MFHILO_T3;

                        `OP_OUT:  next_state = S_OUT_T3;
                        `OP_IN:   next_state = S_IN_T3;

                        `OP_NOP:  next_state = S_NOP_T3;

                        `OP_HALT: begin
                            next_state = S_HALT;
                            next_run   = 1'b0;
                        end

                        default: begin
                            next_state = S_HALT;
                            next_run   = 1'b0;
                        end
                    endcase
                end

                S_ALU_T3: begin
                    Grb       = 1'b1;
                    Rout_dec  = 1'b1;
                    Yin       = 1'b1;
                    next_state = S_ALU_T4;
                end

                S_ALU_T4: begin
                    Grc       = 1'b1;
                    Rout_dec  = 1'b1;
                    op        = alu_from_opcode(opcode);
                    Zin       = 1'b1;
                    next_state = S_ALU_T5;
                end

                S_ALU_T5: begin
                    bus_sel   = SEL_ZLOW;
                    Gra       = 1'b1;
                    Rin_dec   = 1'b1;
                    next_state = S_FETCH0;
                end

                S_UNARY_T3: begin
                    Grb       = 1'b1;
                    Rout_dec  = 1'b1;
                    op        = alu_from_opcode(opcode);
                    Zin       = 1'b1;
                    next_state = S_UNARY_T4;
                end

                S_UNARY_T4: begin
                    bus_sel   = SEL_ZLOW;
                    Gra       = 1'b1;
                    Rin_dec   = 1'b1;
                    next_state = S_FETCH0;
                end

                S_MD_T3: begin
                    Gra       = 1'b1;
                    Rout_dec  = 1'b1;
                    Yin       = 1'b1;
                    next_state = S_MD_T4;
                end

                S_MD_T4: begin
                    Grb       = 1'b1;
                    Rout_dec  = 1'b1;
                    op        = alu_from_opcode(opcode);
                    Zin       = 1'b1;
                    next_state = S_MD_T5;
                end

                S_MD_T5: begin
                    bus_sel   = SEL_ZLOW;
                    LOin      = 1'b1;
                    next_state = S_MD_T6;
                end

                S_MD_T6: begin
                    bus_sel   = SEL_ZHIGH;
                    HIin      = 1'b1;
                    next_state = S_FETCH0;
                end

                S_LD_T3: begin
                    Grb       = 1'b1;
                    Rout_dec  = 1'b1;
                    BAout     = 1'b1;
                    Yin       = 1'b1;
                    next_state = S_LD_T4;
                end

                S_LD_T4: begin
                    Cout      = 1'b1;
                    op        = `ADDop;
                    Zin       = 1'b1;
                    next_state = S_LD_T5;
                end

                S_LD_T5: begin
                    bus_sel   = SEL_ZLOW;
                    MARin     = 1'b1;
                    next_state = S_LD_T6;
                end

                S_LD_T6: begin
                    Read      = 1'b1;
                    MDRin     = 1'b1;
                    next_state = S_LD_T7;
                end

                S_LD_T7: begin
                    bus_sel   = SEL_MDR;
                    Gra       = 1'b1;
                    Rin_dec   = 1'b1;
                    next_state = S_FETCH0;
                end

                S_LDI_T3: begin
                    Grb       = 1'b1;
                    Rout_dec  = 1'b1;
                    BAout     = 1'b1;
                    Yin       = 1'b1;
                    next_state = S_LDI_T4;
                end

                S_LDI_T4: begin
                    Cout      = 1'b1;
                    op        = `ADDop;
                    Zin       = 1'b1;
                    next_state = S_LDI_T5;
                end

                S_LDI_T5: begin
                    bus_sel   = SEL_ZLOW;
                    Gra       = 1'b1;
                    Rin_dec   = 1'b1;
                    next_state = S_FETCH0;
                end

                S_ST_T3: begin
                    Gra       = 1'b1;
                    Rout_dec  = 1'b1;
                    MDRin     = 1'b1;
                    next_state = S_ST_T4;
                end

                S_ST_T4: begin
                    Grb       = 1'b1;
                    Rout_dec  = 1'b1;
                    BAout     = 1'b1;
                    Yin       = 1'b1;
                    next_state = S_ST_T5;
                end

                S_ST_T5: begin
                    Cout      = 1'b1;
                    op        = `ADDop;
                    Zin       = 1'b1;
                    next_state = S_ST_T6;
                end

                S_ST_T6: begin
                    bus_sel   = SEL_ZLOW;
                    MARin     = 1'b1;
                    next_state = S_ST_T7;
                end

                S_ST_T7: begin
                    Write     = 1'b1;
                    next_state = S_FETCH0;
                end

                S_IMM_T3: begin
                    Grb       = 1'b1;
                    Rout_dec  = 1'b1;
                    Yin       = 1'b1;
                    next_state = S_IMM_T4;
                end

                S_IMM_T4: begin
                    Cout      = 1'b1;
                    op        = alu_from_opcode(opcode);
                    Zin       = 1'b1;
                    next_state = S_IMM_T5;
                end

                S_IMM_T5: begin
                    bus_sel   = SEL_ZLOW;
                    Gra       = 1'b1;
                    Rin_dec   = 1'b1;
                    next_state = S_FETCH0;
                end

                S_BR_T3: begin
                    Gra       = 1'b1;
                    Rout_dec  = 1'b1;
                    CONin     = 1'b1;
                    next_state = S_BR_T4;
                end

                S_BR_T4: begin
                    bus_sel   = SEL_PC;
                    Yin       = 1'b1;
                    next_state = S_BR_T5;
                end

                S_BR_T5: begin
                    Cout      = 1'b1;
                    op        = `ADDop;
                    Zin       = 1'b1;
                    next_state = S_BR_T6;
                end

                S_BR_T6: begin
                    bus_sel     = SEL_ZLOW;
                    CON_to_PCin = 1'b1;
                    next_state  = S_FETCH0;
                end

                S_JR_T3: begin
                    Gra       = 1'b1;
                    Rout_dec  = 1'b1;
                    PCin      = 1'b1;
                    next_state = S_FETCH0;
                end

                S_JAL_T3: begin
                    bus_sel    = SEL_PC;
                    Rin[12]    = 1'b1;
                    next_state = S_JAL_T4;
                end

                S_JAL_T4: begin
                    Gra       = 1'b1;
                    Rout_dec  = 1'b1;
                    PCin      = 1'b1;
                    next_state = S_FETCH0;
                end

                S_MFHILO_T3: begin
                    bus_sel   = (opcode == `OP_MFHI) ? SEL_HI : SEL_LO;
                    Gra       = 1'b1;
                    Rin_dec   = 1'b1;
                    next_state = S_FETCH0;
                end

                S_OUT_T3: begin
                    Gra       = 1'b1;
                    Rout_dec  = 1'b1;
                    OutPortin = 1'b1;
                    next_state = S_FETCH0;
                end

                S_IN_T3: begin
                    InPortLoad = 1'b1;
                    next_state = S_IN_T4;
                end

                S_IN_T4: begin
                    InPortout  = 1'b1;
                    Gra        = 1'b1;
                    Rin_dec    = 1'b1;
                    next_state = S_FETCH0;
                end

                S_NOP_T3: begin
                    next_state = S_FETCH0;
                end

                S_HALT: begin
                    next_state = S_HALT;
                    next_run   = 1'b0;
                end

                default: begin
                    next_state = S_HALT;
                    next_run   = 1'b0;
                end
            endcase
        end
    end

endmodule
