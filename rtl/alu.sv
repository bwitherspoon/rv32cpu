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
    input  funct_t fun,
    input  data_t  op1,
    input  data_t  op2,
    output data_t  out
);
    always_comb
        unique case (fun)
            funct::ADD:  out = op1 + op2;
            funct::SUB:  out = op1 - op2;
            funct::SLL:  out = op1 << op2;
            funct::SLT:  out = signed'(op1) < signed'(op2);
            funct::SLTU: out = op1 < op2;
            funct::XOR:  out = op1 ^ op2;
            funct::SRL:  out = op1 >> op2;
            funct::SRA:  out = signed'(op1) >>> op2;
            funct::OR:   out = op1 | op2;
            funct::AND:  out = op1 & op2;
        endcase
endmodule
