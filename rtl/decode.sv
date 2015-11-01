/*
 * decode.sv
 */

import riscv::op2_sel_t;
import riscv::ir_t;
import riscv::word_t;
import riscv::imm_t;
import riscv::opcode_t;
import riscv::funct3_t;
import riscv::funct7_t;
import riscv::addr_t;

/**
 * Module: decode
 *
 * Instruction decode stage
 */
module decode (
    input  logic     clk,
    input  op2_sel_t op2_sel,
    input  ir_t      ir,
    input  word_t    rdata1,
    input  word_t    rdata2,
    output opcode_t  opcode,
    output funct3_t  funct3,
    output funct7_t  funct7,
    output addr_t    raddr1,
    output addr_t    raddr2,
    output word_t    op1,
    output word_t    op2,
    output word_t    rs1
);
    // Immediate sign extension
    imm_t i_imm = imm_t'(ir.i.imm_11_0);
    imm_t s_imm = imm_t'({ir.s.imm_11_5, ir.s.imm_4_0});
    imm_t b_imm = imm_t'({ir.sb.imm_12, ir.sb.imm_11, ir.sb.imm_10_5, ir.sb.imm_4_1, 1'b0});
    imm_t u_imm = imm_t'({ir.u.imm_31_12, 12'd0});
    imm_t j_imm = imm_t'({ir.uj.imm_20, ir.uj.imm_19_12, ir.uj.imm_11, ir.uj.imm_10_1, 1'b0});

    // Control signals
    assign opcode = ir.r.opcode;
    assign funct3 = ir.r.funct3;
    assign funct7 = ir.r.funct7;

    // First operand
    assign op1 = rdata1;

    // Second operand
    always_comb
        case (op2_sel)
            riscv::OP2_RS2:   op2 = rdata2;
            riscv::OP2_I_IMM: op2 = i_imm;
            riscv::OP2_S_IMM: op2 = s_imm;
            riscv::OP2_B_IMM: op2 = b_imm;
            riscv::OP2_U_IMM: op2 = u_imm;
            riscv::OP2_J_IMM: op2 = j_imm;
        endcase

endmodule
