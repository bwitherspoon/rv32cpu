/*
 * alu.sv
 */

import riscv::funct_t;
import riscv::data_t;

/**
 * Module: alu
 *
 * An ALU.
 */
module alu (
    input  funct_t funct,
    input  data_t  op1,
    input  data_t  op2,
    output data_t  out
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
            riscv::SRA:  out = signed'(op1) >>> op2;
            riscv::OR:   out = op1 | op2;
            riscv::AND:  out = op1 & op2;
        endcase
endmodule
