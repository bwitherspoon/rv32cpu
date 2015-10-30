/*
 * regfile.sv
 */

import riscv::addr_t;
import riscv::word_t;

/**
 * Module: regfile
 *
 * A register file.
 */
module regfile (
    input  logic  clk,

    input  addr_t raddr1,
    output word_t rdata1,

    input  addr_t raddr2,
    output word_t rdata2,

    input  logic  wen,
    input  addr_t waddr,
    input  word_t wdata
);

    localparam ADDR_WIDTH = $bits(addr_t);

    word_t regs [0:2**ADDR_WIDTH-2];

`ifndef SYNTHESIS
    initial
        for (int i = 0; i < 2**ADDR_WIDTH-1; i = i + 1)
            regs[i] = 0;
`endif

    logic rzero1 = raddr1 == 'b0;
    logic rzero2 = raddr2 == 'b0;
    logic wzero  = waddr  == 'b0;

    always @(negedge clk)
        if (wen && ~wzero)
            regs[waddr - 1] <= wdata;

    assign rdata1 = rzero1 ? 'b0 : regs[raddr1 - 1];
    assign rdata2 = rzero2 ? 'b0 : regs[raddr2 - 1];

endmodule
