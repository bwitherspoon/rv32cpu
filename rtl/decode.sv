/*
 * decode.sv
 */

import riscv::pc_t;
import riscv::word_t;
import riscv::imm_t;
import riscv::opcode_t;
import riscv::funct3_t;
import riscv::funct7_t;

/**
 * Module: decode
 */
module decode (
    input  logic       clk,
    input  logic [1:0] rs1_sel,
    input  logic [1:0] rs2_sel,
    input  logic [2:0] op2_sel,
    input  pc_t        ir,
    input  word_t      bypass_alu,
    input  word_t      bypass_mem,
    input  word_t      bypass_wb,
    output opcode_t    opcode,
    output funct3_t    funct3,
    output funct7_t    funct7,
    output word_t      rs1,
    output wort_t      rs2,
    output word_t      op2
);
    // Immediate sign extension
    imm_t i_imm = imm_t'(
        {ir.i.imm_20, ir.i.imm_10_5, ir.i.imm_4_1, ir.i.imm_0});
    imm_t s_imm = imm_t'(
        {ir.s.imm_11, ir.s.imm_10_5, ir.s.imm_4_1, ir.s.imm_0});
    imm_t b_imm = imm_t'(
        {ir.sb.imm_12, ir.sb.imm_11, ir.sb.imm_10_5, ir.sb.imm_4_1, ir.sb.imm_0, 1'b0});
    imm_t u_imm = imm_t'(
        {ir.u.imm_31, ir.u.imm_30_20, ir.u.imm_19_15, ir.u.imm_14_12, 12'd0});
    imm_t j_imm = imm_t'(
        {ir.uj.imm_20, ir.uj.imm_19_15, ir.uj.imm_14_12, ir.uj.imm_11, ir.uj.imm_10_5, ir.uj.imm_4_1, 1'b0});

    // Control signals
    assign opcode = ir.r.opcode;
    assign funct3 = ir.r.funct3;
    assign funct7 = ir.r.funct7;

endmodule
