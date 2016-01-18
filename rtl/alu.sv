/*
 * Copyright (c) 2015, C. Brett Witherspoon
 */

/**
 * Module: alu
 *
 * An arithmetic and logic unit (ALU) for RISC-V
 */
module alu
    import core::fun_t;
    import core::word_t;
(
    input  fun_t    fun,
    input  word_t   op1,
    input  word_t   op2,
    output word_t   out
);
    wire [4:0] shamt = op2[4:0];

    always_comb
        unique case (fun)
            core::ADD:  out = op1 + op2;
            core::SUB:  out = op1 - op2;
            core::SLL:  out = op1 << shamt;
            core::SLT:  out = word_t'(signed'(op1) < signed'(op2));
            core::SLTU: out = word_t'(op1 < op2);
            core::XOR:  out = op1 ^ op2;
            core::SRL:  out = op1 >> shamt;
            core::SRA:  out = signed'(op1) >>> shamt;
            core::OR:   out = op1 | op2;
            core::AND:  out = op1 & op2;
            core::OP2:  out = op2;
            default:  out = 'x;
        endcase
endmodule
