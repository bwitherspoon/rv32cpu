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
    input  addr_t rs1_addr,
    input  addr_t rs2_addr,
    output word_t rs1_data,
    output word_t rs2_data,
    input  logic  rd_en,
    input  addr_t rd_addr,
    input  word_t rd_data
);

    word_t regs [0:2**$bits(addr_t)-1];

`ifndef SYNTHESIS
    initial
        for (int i = 0; i < 2**$bits(addr_t)-1; i++)
            regs[i] = $random;
`endif

    always @(negedge clk)
        if (rd_en && rd_addr != '0)
            regs[rd_addr] <= rd_data;

    assign rs1_data = rs1_addr == '0 ? '0 : regs[rs1_addr];
    assign rs2_data = rs2_addr == '0 ? '0 : regs[rs2_addr];

endmodule
