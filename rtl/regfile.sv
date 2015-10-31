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

    word_t regs [0:2**$bits(addr_t)-1];

`ifndef SYNTHESIS
    initial
        for (int i = 0; i < 2**$bits(addr_t)-1; i = i + 1)
            regs[i] = 0;
`endif

    always @(negedge clk)
        if (wen && waddr != 'd0)
            regs[waddr] <= wdata;

    assign rdata1 = raddr1 == 'd0 ? 'd0 : regs[raddr1];
    assign rdata2 = raddr2 == 'd0 ? 'd0 : regs[raddr2];

endmodule
