module con_ff_logic (
    input  wire        clk,
    input  wire        reset,
    input  wire        CONin,
    input  wire [31:0] bus_value,
    input  wire [1:0]  c2,
    output reg         CON_q
);
    reg cond_eval;

    always @(*) begin
        case (c2)
            2'b00: cond_eval = (bus_value == 32'b0);                              // brzr
            2'b01: cond_eval = (bus_value != 32'b0);                              // brnz
            2'b10: cond_eval = (~bus_value[31]) & (bus_value != 32'b0);           // brpl
            2'b11: cond_eval = bus_value[31];                                      // brmi
            default: cond_eval = 1'b0;
        endcase
    end

    always @(posedge clk) begin
        if (reset) begin
            CON_q <= 1'b0;
        end else if (CONin) begin
            CON_q <= cond_eval;
        end
    end
endmodule
