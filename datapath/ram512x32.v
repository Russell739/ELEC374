module ram512x32 #(
    parameter MEM_INIT_FILE = ""
) (
    input  wire        clk,
    input  wire        write_en,
    input  wire [8:0]  addr,
    input  wire [31:0] write_data,
    output wire [31:0] read_data,
    input  wire [8:0]  dbg_addr,
    output wire [31:0] dbg_data
);
    reg [31:0] mem [0:511];
    integer i;

    initial begin
        for (i = 0; i < 512; i = i + 1) begin
            mem[i] = 32'b0;
        end
        if (MEM_INIT_FILE != "") begin
            $readmemh(MEM_INIT_FILE, mem);
        end
    end

    always @(posedge clk) begin
        if (write_en) begin
            mem[addr] <= write_data;
        end
    end

    assign read_data = mem[addr];
    assign dbg_data  = mem[dbg_addr];
endmodule
