/*
 * regfile.sv
 */

import riscv::addr_t;
import riscv::data_t;

/**
 * Module: regfile
 *
 * A register file.
 */
module regfile (
    input  logic  clk,

    input  addr_t raddr1,
    output data_t rdata1,

    input  addr_t raddr2,
    output data_t rdata2,

    input  logic  wen,
    input  addr_t waddr,
    input  data_t wdata
);

    data_t regs [0:2**$bits(addr_t)-1];

`ifndef SYNTHESIS
    initial
        for (int i = 0; i < 2**$bits(addr_t)-1; i++)
            regs[i] = 0;
`endif

    always @(negedge clk)
        if (wen && waddr != '0)
            regs[waddr] <= wdata;

    assign rdata1 = raddr1 == '0 ? '0 : regs[raddr1];
    assign rdata2 = raddr2 == '0 ? '0 : regs[raddr2];

endmodule
