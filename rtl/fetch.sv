/*
 * fetch.sv
 */

import riscv::pc_t;
import riscv::ir_t;

/**
 * Module: fetch
 *
 * Instruction fetch stage
 */
module fetch (
    input  logic    clk,
    input  logic    resetn,
    input  logic    bubble,
    input  logic    jump,
    input  pc_t     target,
    output pc_t     pc,
    output ir_t     ir,
    output logic    misaligned
);
    // Internal signals
    pc_t pc_i;
    ir_t ir_i;
    pc_t tgt;

    // Instruction memory
    ir_t mem [0:2**($bits(pc_t)-4)-1];

    always_ff @(posedge clk)
        ir_i <= mem[pc_i[$bits(pc_i)-1:4]];

    // Instruction register
    assign ir = (bubble | ~resetn) ? riscv::NOP : ir_i;

    // Program counter
    always_ff @(posedge clk)
        if (~resetn)
            pc_i <= riscv::INIT_PC;
        else if (~bubble)
            pc_i <= tgt;

   always_ff @(posedge clk)
        pc <= pc_i;

    // Misaligned exception
    assign misaligned = pc_i[2:0] != 2'b00;

    // Target
    assign tgt = (jump) ? target : pc + 4;

endmodule
