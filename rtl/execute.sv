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
    input  funct_t funct,
    input  data_t  op1,
    input  data_t  op2,
    output data_t  out,
    output pc_t    jal_bxx_tgt,
    output pc_t    jalr_tgt,
    output logic   eq,
    output logic   lt,
    output logic   ltu
);

    alu alu (
        .funct(funct),
        .op1(op1),
        .op2(op2),
        .out(out)
    );

endmodule
