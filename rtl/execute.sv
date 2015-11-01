/*
 * execute.sv
 */

import riscv::pc_t;
import riscv::aluop_t;
import riscv::data_t;

/**
 * Module: execute
 */
module execute (
    input  logic   clk,
    input  pc_t    pc,
    input  aluop_t aluop,
    input  data_t  op1,
    input  data_t  op2,
    output data_t  result,
    output pc_t    target,
    output logic   equal,
    output logic   less
);

    alu alu (
        .opcode(aluop),
        .op1(op1),
        .op2(op2),
        .out(result)
    );

endmodule
