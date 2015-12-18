/*
 * alu.sv
 */

import riscv::*;

/**
 * Module: alu
 *
 * An ALU.
 */
module alu (
    input  alu_t  opcode,
    input  data_t op1,
    input  data_t op2,
    output data_t out
);
    logic [6:0] shamt = op2[5:0];

    always_comb
        unique case (opcode)
            ALU_ADD:  out = op1 + op2;
            ALU_SUB:  out = op1 - op2;
            ALU_SLL:  out = op1 << shamt;
            ALU_SLT:  out = signed'(op1) < signed'(op2);
            ALU_SLTU: out = op1 < op2;
            ALU_XOR:  out = op1 ^ op2;
            ALU_SRL:  out = op1 >> shamt;
            ALU_SRA:  out = signed'(op1) >>> shamt;
            ALU_OR:   out = op1 | op2;
            ALU_AND:  out = op1 & op2;
            ALU_OP2:  out = op2;
            ALU_XXX:  out = 'x;
        endcase
endmodule
