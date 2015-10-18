module block_ram #(
    parameter int unsigned ADDR_WIDTH = 9,
    parameter int unsigned DATA_WIDTH = 32
)(
    input  logic                  clk,
    // Port A
    input  logic [DATA_WIDTH/8-1:0] we_a,
    input  logic [ADDR_WIDTH-1:0]   addr_a,
    input  logic [DATA_WIDTH-1:0]   wdata_a,
    output logic [DATA_WIDTH-1:0]   rdata_a,
    // Port B
    input  logic [DATA_WIDTH/8-1:0] we_b,
    input  logic [ADDR_WIDTH-1:0]   addr_b,
    input  logic [DATA_WIDTH-1:0]   wdata_b,
    output logic [DATA_WIDTH-1:0]   rdata_b
);
    localparam int unsigned DATA_BYTES = DATA_WIDTH / 8;

    logic [DATA_WIDTH-1:0] ram [0:2**ADDR_WIDTH-1];

    // Port A (with byte write enable)
    always_ff @(posedge clk) begin
        for (int i = 0; i < DATA_BYTES; i = i + 1)
            if (we_a[i])
                ram[addr_a][8*i +: 8] <= wdata_a[8*i +: 8];
        rdata_a <= ram[addr_a];
    end

    // Port A (with byte write enable)
    always_ff @(posedge clk) begin
        for (int i = 0; i < DATA_BYTES; i = i + 1)
            if (we_b[i])
                ram[addr_b][8*i +: 8] <= wdata_b[8*i +: 8];
        rdata_b <= ram[addr_b];
    end

endmodule
