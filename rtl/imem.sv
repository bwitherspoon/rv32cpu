/**
 * Module: imem
 * 
 * Byte addressable instruction memory
 */
module imem #(
    parameter ADDR_WIDTH = 9,
    parameter DATA_WIDTH = 32
)(
    input  logic                  clk,
    input  logic [ADDR_WIDTH-1:0] addr,
    output logic [DATA_WIDTH-1:0] data
);

    localparam DATA_BYTES = DATA_WIDTH / 8;
    
    logic [7:0] mem [0:2**ADDR_WIDTH-1];
  
    always_ff @(posedge clk)
        for (int i = 0; i < DATA_BYTES; i = i + 1)
            data[8*i +: 8] <= mem[addr + i];

endmodule


