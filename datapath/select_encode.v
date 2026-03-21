module select_encode (
    input  wire [31:0] IR,
    input  wire        Gra,
    input  wire        Grb,
    input  wire        Grc,
    input  wire        Rin_sel,
    input  wire        Rout_sel,
    output reg  [15:0] Rin_decoded,
    output reg  [15:0] Rout_decoded,
    output reg  [3:0]  selected_reg
);
    reg [15:0] onehot;

    always @(*) begin
        if (Gra) begin
            selected_reg = IR[26:23];
        end else if (Grb) begin
            selected_reg = IR[22:19];
        end else if (Grc) begin
            selected_reg = IR[18:15];
        end else begin
            selected_reg = 4'd0;
        end

        onehot = 16'b0;
        onehot[selected_reg] = 1'b1;

        if (Rin_sel === 1'b1) begin
            Rin_decoded = onehot;
        end else begin
            Rin_decoded = 16'b0;
        end

        if (Rout_sel === 1'b1) begin
            Rout_decoded = onehot;
        end else begin
            Rout_decoded = 16'b0;
        end
    end
endmodule
