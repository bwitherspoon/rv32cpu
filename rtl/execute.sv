/*
 * execute.sv
 */

import riscv::pc_t;
import riscv::aluop_t;
import riscv::data_t;
import riscv::reg_t;

/**
 * Module: execute
 */
module execute (
    input  logic   clk,
    input  pc_t    pc,
    input  aluop_t aluop,
    input  data_t  op1,
    input  data_t  op2,
    input  data_t  rs2_id,
    input  reg_t   rd_id,
    output data_t  result,
    output pc_t    target,
    output logic   equal,
    output logic   less,
    output data_t  rs2_ex,
    output reg_t   rd_ex
);

    alu alu (
        .opcode(aluop),
        .op1(op1),
        .op2(op2),
        .out(result)
    );

    // Pipeline registers
    always_ff @(posedge clk) begin
        rs2_ex <= rs2_id;
        rd_ex  <= rd_id;
    end
    
endmodule
