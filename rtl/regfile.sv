/*
 * Copyright (c) 2015-2018 C. Brett Witherspoon
 */

/**
 * Module: regfile
 *
 * A 32 width and 32 depth register file with two read and one write port..
 */
module regfile
    import rv32::addr_t;
    import rv32::word_t;
(
    input  logic  clk,
    input  addr_t rs1_addr,
    input  addr_t rs2_addr,
    output word_t rs1_data,
    output word_t rs2_data,
    input  logic  rd_en,
    input  addr_t rd_addr,
    input  word_t rd_data
);

    word_t regs [1:2**$bits(addr_t)-1];

`ifndef SYNTHESIS
    initial for (int i = 1; i < 2**$bits(addr_t); i++) regs[i] = '0;
`endif

    always @(posedge clk)
        if (rd_en && rd_addr != '0)
            regs[rd_addr] <= rd_data;

    assign rs1_data = rs1_addr == '0 ? '0 : regs[rs1_addr];
    assign rs2_data = rs2_addr == '0 ? '0 : regs[rs2_addr];

endmodule
