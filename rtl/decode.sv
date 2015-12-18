/*
 * decode.sv
 */

import riscv::*;

/**
 * Module: decode
 *
 * Instruction decode stage
 */
module decode (
    input  logic     clk,
    input  op1_sel_t op1_sel,
    input  op2_sel_t op2_sel,
    input  pc_t      pc_id,
    input  ir_t      ir,
    input  data_t    rdata1,
    input  data_t    rdata2,
    output reg_t     raddr1,
    output reg_t     raddr2,
    output opcode_t  opcode,
    output funct3_t  funct3,
    output funct7_t  funct7,
    output pc_t      pc_ex,
    output data_t    op1,
    output data_t    op2,
    output data_t    rs1,
    output data_t    rs2,
    output reg_t     rd
);
    // Immediate sign extension
    imm_t i_imm;
    imm_t s_imm;
    imm_t b_imm;
    imm_t u_imm;
    imm_t j_imm;

    assign i_imm = signed'(ir.i.imm_11_0);
    assign s_imm = signed'({ir.s.imm_11_5, ir.s.imm_4_0});
    assign b_imm = signed'({ir.sb.imm_12, ir.sb.imm_11, ir.sb.imm_10_5, ir.sb.imm_4_1, 1'b0});
    assign u_imm = signed'({ir.u.imm_31_12, 12'd0});
    assign j_imm = signed'({ir.uj.imm_20, ir.uj.imm_19_12, ir.uj.imm_11, ir.uj.imm_10_1, 1'b0});

    // Register file addresses
    assign raddr1 = ir.r.rs1;
    assign raddr2 = ir.r.rs2;

    // Control signals
    assign opcode = ir.r.opcode;
    assign funct3 = ir.r.funct3;
    assign funct7 = ir.r.funct7;

    // First operand
    data_t op1_mux;

    always_comb
        unique case (op1_sel)
            OP1_RS1: op1_mux = rdata1;
            OP1_PC:  op1_mux = pc_id;
            OP1_XXX: op1_mux = 'x;
        endcase

    // Second operand
    data_t op2_mux;

    always_comb
        unique case (op2_sel)
            OP2_RS2:   op2_mux = rdata2;
            OP2_I_IMM: op2_mux = i_imm;
            OP2_S_IMM: op2_mux = s_imm;
            OP2_B_IMM: op2_mux = b_imm;
            OP2_U_IMM: op2_mux = u_imm;
            OP2_J_IMM: op2_mux = j_imm;
            OP2_XXX:   op2_mux = 'x;
        endcase

    // Pipeline registers
    always_ff @(posedge clk) begin
        op1   <= op1_mux;
        op2   <= op2_mux;
        rs1   <= rdata1;
        rs2   <= rdata2;
        rd    <= ir.r.rd;
        pc_ex <= pc_id;
    end

endmodule
