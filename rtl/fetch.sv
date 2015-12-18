/*
 * fetch.sv
 */

import riscv::ir_t;
import riscv::pc_sel_t;
import riscv::pc_t;

/**
 * Module: fetch
 *
 * Instruction fetch stage
 */
module fetch (
    input  logic    clk,
    input  logic    resetn,
    input  pc_t     target,
    input  pc_sel_t pc_sel,
    output pc_t     pc,
    output ir_t     ir
);
    // Internal signals
    pc_t pc_next;

    // Instruction memory
    logic [7:0] mem [0:2**$bits(pc_t)-1];

    always_ff @(posedge clk)
        for (pc_t i = 0; i < $bits(ir_t)/8; i++)
            ir[8*i +: 8] <= mem[pc_next + i];

    // Program counter
   always_ff @(posedge clk)
       pc <= pc_next;

    always_ff @(posedge clk)
        if (~resetn)
            pc_next <= riscv::INIT_ADDR;
        else
            unique case (pc_sel)
                riscv::PC_TARGET: pc_next <= target;
                riscv::PC_TRAP:   pc_next <= riscv::TRAP_ADDR;
                default:          pc_next <= pc_next + 4;
            endcase
endmodule
