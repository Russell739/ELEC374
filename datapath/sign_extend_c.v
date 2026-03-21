module sign_extend_c (
    input  wire [31:0] IR,
    input  wire        Cout,
    output wire [31:0] C_sign_extended
);
    wire [31:0] sext_c = {{13{IR[18]}}, IR[18:0]};
    assign C_sign_extended = Cout ? sext_c : 32'b0;
endmodule
