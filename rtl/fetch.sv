/*
 * fetch.sv
 */

import riscv::tgt_t;
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
    input  tgt_t    target,
    input  pc_t     jal_bxx_tgt,
    input  pc_t     jalr_tgt,
    output pc_t     pc,
    output ir_t     ir,
    output logic    misaligned
);

    pc_t pc_i;
    ir_t ir_i;
    pc_t tgt;
    ir_t mem [0:2**($bits(pc_t)-4)-1];

    // Instruction memory
    always_ff @(posedge clk)
        ir_i <= mem[pc_i[$bits(pc_i)-1:4]];

    // IR
    assign ir = (bubble | ~resetn) ? riscv::NOP : ir_i;

    // PC
    always_ff @(posedge clk)
        if (~resetn)
            pc_i <= riscv::BOOT_ADDR;
        else if (~bubble)
            pc_i <= tgt;

   always_ff @(posedge clk)
        pc <= pc_i;

    // Target
    always_comb
        case (target)
            riscv::JALR_TGT:     tgt = jalr_tgt;
            riscv::JAL_BXX_TGT:  tgt = jal_bxx_tgt;
            riscv::PC_PLUS4_TGT: tgt = pc + 4;
        endcase

endmodule
