/*
 * fetch.sv
 */

import riscv::pc_sel_t;
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
    input  pc_sel_t pc_sel,
    input  pc_t     jal_bxx_tgt,
    input  pc_t     jalr_tgt,
    output pc_t     pc,
    output ir_t     ir
);

    ir_t ir_i;
    pc_t pc_i;
    pc_t pc_tgt;

    imem imem (
        .clk(clk),
        .addr(pc_i),
        .data(ir_i)
    );

    assign ir = (bubble | ~resetn) ? riscv::NOP : ir_i;

    always_ff @(posedge clk)
        if (~resetn)
            pc <= 'h2000;
        else if (~bubble)
            pc <= pc_tgt;

    always_comb
        case (pc_sel)
            riscv::JALR: pc_tgt = jalr_tgt;
            riscv::JAL:  pc_tgt = jal_bxx_tgt;
            riscv::NEXT: pc_tgt = pc + 4;
        endcase

endmodule
