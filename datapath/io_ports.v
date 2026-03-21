module io_ports (
    input  wire        clk,
    input  wire        reset,
    input  wire        OutPortin,
    input  wire [31:0] bus_in,
    input  wire        InPortLoad,
    input  wire [31:0] InPort_data,
    output reg  [31:0] OutPort_q,
    output reg  [31:0] InPort_q
);
    always @(posedge clk) begin
        if (reset) begin
            OutPort_q <= 32'b0;
            InPort_q  <= 32'b0;
        end else begin
            if (OutPortin) begin
                OutPort_q <= bus_in;
            end
            if (InPortLoad) begin
                InPort_q <= InPort_data;
            end
        end
    end
endmodule
