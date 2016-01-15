/*
 * Copyright (c) 2015, C. Brett Witherspoon
 */

/**
 * Module: alu
 *
 * An arithmetic and logic unit (ALU) for RISC-V
 */
module alu
    import riscv::*;
(
    input  alu_op_t opcode,
    input  word_t   op1,
    input  word_t   op2,
    output word_t   out
);
    wire [4:0] shamt = op2[4:0];

    always_comb
        unique case (opcode)
            ALU_ADD:  out = op1 + op2;
            ALU_SUB:  out = op1 - op2;
            ALU_SLL:  out = op1 << shamt;
            ALU_SLT:  out = word_t'(signed'(op1) < signed'(op2));
            ALU_SLTU: out = word_t'(op1 < op2);
            ALU_XOR:  out = op1 ^ op2;
            ALU_SRL:  out = op1 >> shamt;
            ALU_SRA:  out = signed'(op1) >>> shamt;
            ALU_OR:   out = op1 | op2;
            ALU_AND:  out = op1 & op2;
            ALU_OP2:  out = op2;
            default:  out = 'x;
        endcase
endmodule
