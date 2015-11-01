/*
 * execute.sv
 */
 
import riscv::pc_t;
import riscv::funct_t;
import riscv::data_t;
 
/**
 * Module: execute
 */
module execute (
    input  logic   clk,
    input  pc_t    pc,
    input  funct_t fun,
    input  data_t  op1,
    input  data_t  op2,
    output data_t  out,
    output pc_t    target,
    output logic   eq,
    output logic   lt,
    output logic   ltu
);

    alu alu (
        .fun(fun),
        .op1(op1),
        .op2(op2),
        .out(out)
    );

endmodule
