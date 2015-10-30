/*
 * imem.sv
 */

import riscv::pc_t;
import riscv::word_t;

/**
 * Module: imem
 *
 * Byte addressable instruction memory
 */
module imem (
    input  logic  clk,
    input  pc_t   addr,
    output word_t data
);

    logic [7:0] mem [0:2**$bits(pc_t)-1];

    always_ff @(posedge clk)
        for (int i = 0; i < $bits(word_t) / 8; i = i + 1)
            data[8*i +: 8] <= mem[addr + i];

endmodule
