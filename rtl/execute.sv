/*
 * execute.sv
 */

import riscv::alu_t;
import riscv::data_t;
import riscv::pc_t;
import riscv::reg_t;

/**
 * Module: execute
 */
module execute (
    input  logic  clk,
    input  alu_t  alu_op,
    input  logic  link,
    input  pc_t   pc,
    input  data_t op1,
    input  data_t op2,
    input  data_t rs1,
    input  data_t rs2_ex,
    input  reg_t  rd_ex,
    output data_t val,
    output pc_t   target,
    output data_t rs2_mem,
    output reg_t  rd_mem,
    output logic  eq,
    output logic  lt,
    output logic  ltu
);

    data_t result;

    alu alu (
        .opcode(alu_op),
        .op1(op1),
        .op2(op2),
        .out(result)
    );

    assign target = result[$bits(target)-1:0];

    // Comparators
    assign eq  = rs1 == rs2_ex;
    assign lt  = signed'(rs1) < signed'(rs2_ex);
    assign ltu = rs1 < rs2_ex;

    // Pipeline registers
    always_ff @(posedge clk) begin
        rs2_mem <= rs2_ex;
        rd_mem  <= rd_ex;
        val   <= (link) ? pc + 4 : result;
    end

endmodule
