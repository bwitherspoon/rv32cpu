/*
 * Copyright (c) 2015-2018 C. Brett Witherspoon
 */

/**
 * Module: alu
 *
 * An arithmetic and logic unit (ALU) for RISC-V
 */
module alu
    import rv32::fn_t;
    import rv32::word_t;
(
    input  fn_t   fn,
    input  word_t op1,
    input  word_t op2,
    output word_t out
);
    wire [4:0] shamt = op2[4:0];

    always_comb
        unique case (fn)
            rv32::ADD:  out = op1 + op2;
            rv32::SUB:  out = op1 - op2;
            rv32::SLL:  out = op1 << shamt;
            rv32::SLT:  out = word_t'(signed'(op1) < signed'(op2));
            rv32::SLTU: out = word_t'(op1 < op2);
            rv32::XOR:  out = op1 ^ op2;
            rv32::SRL:  out = op1 >> shamt;
            rv32::SRA:  out = signed'(op1) >>> shamt;
            rv32::OR:   out = op1 | op2;
            rv32::AND:  out = op1 & op2;
            rv32::OP2:  out = op2;
            default:    out = 'x;
        endcase
endmodule
