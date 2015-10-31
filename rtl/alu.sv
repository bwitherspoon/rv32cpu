/*
 * alu.sv
 */

import riscv::funct_t;
import riscv::shamt_t;
import riscv::word_t;

/**
 * Module: alu
 *
 * An ALU.
 */
module alu (
    input  funct_t funct,
    input  shamt_t shamt,
    input  word_t  op1,
    input  word_t  op2,
    output word_t  out
);
    always_comb
        unique case (funct)
            riscv::ADD:  out = op1 + op2;
            riscv::SUB:  out = op1 - op2;
            riscv::SLL:  out = op1 << op2;
            riscv::SLT:  out = signed'(op1) < signed'(op2);
            riscv::SLTU: out = op1 < op2;
            riscv::XOR:  out = op1 ^ op2;
            riscv::SRL:  out = op1 >> op2;
            riscv::SRA:  out = signed'(op1) >> op2;
            riscv::OR:   out = op1 | op2;
            riscv::AND:  out = op1 & op2;
        endcase
endmodule
