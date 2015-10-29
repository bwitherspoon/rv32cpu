/**
 * Module: regfile
 * 
 * A register file.
 */
module regfile #(
    parameter ADDR_WIDTH = 5,
    parameter DATA_WIDTH = 32
)(
    input  logic                  clk,

    input  logic [ADDR_WIDTH-1:0] raddr1,
    output logic [DATA_WIDTH-1:0] rdata1,

    input  logic [ADDR_WIDTH-1:0] raddr2,
    output logic [DATA_WIDTH-1:0] rdata2,

    input  logic                  wen,
    input  logic [ADDR_WIDTH-1:0] waddr,
    input  logic [DATA_WIDTH-1:0] wdata
);

    logic [DATA_WIDTH-1:0] regs [0:2**ADDR_WIDTH-2];

`ifndef SYNTHESIS
    initial for (int i = 0; i < 2**ADDR_WIDTH-1; i = i + 1) regs[i] = 0;
`endif
    
    logic rzero1 = raddr1 == {ADDR_WIDTH{1'b0}};
    logic rzero2 = raddr2 == {ADDR_WIDTH{1'b0}};
    logic wzero  = waddr  == {ADDR_WIDTH{1'b0}};

    always @(negedge clk)
        if (wen && ~wzero)
            regs[waddr - 1] <= wdata;

    assign rdata1 = rzero1 ? {DATA_WIDTH{1'b0}} : regs[raddr1 - 1];
    assign rdata2 = rzero2 ? {DATA_WIDTH{1'b0}} : regs[raddr2 - 1];

endmodule
