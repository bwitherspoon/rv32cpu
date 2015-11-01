/*
 * decode.sv
 */

import riscv::op1_sel_t;
import riscv::op2_sel_t;
import riscv::ir_t;
import riscv::data_t;
import riscv::imm_t;
import riscv::opcode_t;
import riscv::funct3_t;
import riscv::funct7_t;
import riscv::reg_t;

/**
 * Module: decode
 *
 * Instruction decode stage
 */
module decode (
    input  logic     clk,
    input  op1_sel_t op1_sel,
    input  op2_sel_t op2_sel,
    input  pc_t      pc,
    input  ir_t      ir,
    input  data_t    rdata1,
    input  data_t    rdata2,
    output reg_t     raddr1,
    output reg_t     raddr2,
    output opcode_t  opcode,
    output funct3_t  funct3,
    output funct7_t  funct7,
    output data_t    op1,
    output data_t    op2,
    output data_t    rs2,
    output reg_t     rd
);
    // Immediate sign extension
    imm_t i_imm = signed'(ir.i.imm_11_0);
    imm_t s_imm = signed'({ir.s.imm_11_5, ir.s.imm_4_0});
    imm_t b_imm = signed'({ir.sb.imm_12, ir.sb.imm_11, ir.sb.imm_10_5, ir.sb.imm_4_1, 1'b0});
    imm_t u_imm = signed'({ir.u.imm_31_12, 12'd0});
    imm_t j_imm = signed'({ir.uj.imm_20, ir.uj.imm_19_12, ir.uj.imm_11, ir.uj.imm_10_1, 1'b0});

    // Register file addresses
    assign raddr1 = ir.r.rs1;
    assign raddr1 = ir.r.rs2;

    // Control signals
    assign opcode = ir.r.opcode;
    assign funct3 = ir.r.funct3;
    assign funct7 = ir.r.funct7;

    // First operand
    data_t op1_mux = (op1_sel == riscv::RS1) ? rdata1 : pc;

    // Second operand
    data_t op2_mux;
    always_comb
        unique case (op2_sel)
            riscv::RS2:   op2_mux = rdata2;
            riscv::I_IMM: op2_mux = i_imm;
            riscv::S_IMM: op2_mux = s_imm;
            riscv::B_IMM: op2_mux = b_imm;
            riscv::U_IMM: op2_mux = u_imm;
            riscv::J_IMM: op2_mux = j_imm;
            riscv::FOUR:  op2_mux = 'd4;
        endcase

    // Pipeline registers
    always_ff @(posedge clk) begin
        op1 <= op1_mux;
        op2 <= op2_mux;
        rs2 <= rdata2;
        rd  <= ir.r.rd;
    end

endmodule
