/*
 * control.sv
 */

import riscv::*;

/**
 * Module: control
 *
 * Control unit
 */
module control (
     input  logic    clk,
     input  logic    resetn,
     input  opcode_t opcode,
     input  funct3_t funct3,
     input  funct7_t funct7,
     input  logic    eq,
     input  logic    lt,
     input  logic    ltu,
     output ctrl_t   ctrl
);
    // Instuction control structures
    localparam ctrl_t CTRL_INVALID = '{
        reg_en:  1'b0,
        mem_op:  NONE,
        link_en: 1'bx,
        alu_op:  ALU_XXX,
        pc_sel:  PC_TRAP,
        op1_sel: OP1_XXX,
        op2_sel: OP2_XXX
    };
    localparam ctrl_t CTRL_NOP = '{
        reg_en:  1'b0,
        mem_op:  NONE,
        link_en: 1'bx,
        alu_op:  ALU_XXX,
        pc_sel:  PC_NEXT,
        op1_sel: OP1_XXX,
        op2_sel: OP2_XXX
    };
    localparam ctrl_t CTRL_ADDI = '{
        reg_en:  1'b1,
        mem_op:  NONE,
        link_en: 1'b0,
        alu_op:  ALU_ADD,
        pc_sel:  PC_NEXT,
        op1_sel: OP1_RS1,
        op2_sel: OP2_I_IMM
    };
    localparam ctrl_t CTRL_LUI = '{
        reg_en:  1'b1,
        mem_op:  NONE,
        link_en: 1'b0,
        alu_op:  ALU_OP2,
        pc_sel:  PC_NEXT,
        op1_sel: OP1_XXX,
        op2_sel: OP2_U_IMM
    };
    localparam ctrl_t CTRL_AUIPC = '{
        reg_en:  1'b1,
        mem_op:  NONE,
        link_en: 1'b0,
        alu_op:  ALU_ADD,
        pc_sel:  PC_NEXT,
        op1_sel: OP1_PC,
        op2_sel: OP2_U_IMM
    };
    localparam ctrl_t CTRL_ADD = '{
        reg_en:  1'b1,
        mem_op:  NONE,
        link_en: 1'b0,
        alu_op:  ALU_ADD,
        pc_sel:  PC_NEXT,
        op1_sel: OP1_RS1,
        op2_sel: OP2_RS2
    };
    localparam ctrl_t CTRL_SUB = '{
        reg_en:  1'b1,
        mem_op:  NONE,
        link_en: 1'b0,
        alu_op:  ALU_SUB,
        pc_sel:  PC_NEXT,
        op1_sel: OP1_RS1,
        op2_sel: OP2_RS2
    };

    // Pipeline control signals
    ctrl_t id = CTRL_NOP;

    struct packed {
        logic    reg_en;
        mem_op_t mem_op;
        logic    link_en;
        alu_op_t alu_op;
        pc_sel_t pc_sel;
    } ex;

    struct packed {
        logic    reg_en;
        mem_op_t mem_op;
    } mem;

    struct packed {
        logic reg_en;
    } wb;

    // Decode stage
    always_comb
        unique case (opcode)
            OPCODE_OP_IMM:
                unique case (funct3)
                    FUNCT3_ADDI:
                        id = CTRL_ADDI;
                    default:
                        id = CTRL_INVALID;
                endcase
            OPCODE_OP:
                unique case (funct3)
                    FUNCT3_ADD_SUB:
                        id = (funct7[5]) ? CTRL_ADD : CTRL_SUB;
                    default:
                        id = CTRL_INVALID;
                endcase
            OPCODE_LUI:
                id = CTRL_LUI;
            OPCODE_AUIPC:
                id = CTRL_AUIPC;
            default:
                id = CTRL_INVALID;
        endcase

    // Execute stage
    always_ff @(posedge clk)
        if (~resetn) begin
            ex.reg_en <= 1'b0;
            ex.mem_op <= NONE;
            ex.pc_sel <= PC_NEXT;
        end else begin
            ex.reg_en  <= id.reg_en;
            ex.mem_op  <= id.mem_op;
            ex.link_en <= id.link_en;
            ex.alu_op  <= id.alu_op;
            ex.pc_sel  <= id.pc_sel;
        end

    // Memory stage
    always_ff @(posedge clk)
        if (~resetn) begin
            mem.reg_en <= 1'b0;
            mem.mem_op <= NONE;
        end else begin
            mem.reg_en <= ex.reg_en;
            mem.mem_op <= ex.mem_op;
        end

    // Writeback stage
    always_ff @(posedge clk)
        if (~resetn)
            wb.reg_en <= 1'b0;
        else
            wb.reg_en <= mem.reg_en;

    // Output control
    assign ctrl.reg_en  = wb.reg_en;
    assign ctrl.mem_op  = mem.mem_op;
    assign ctrl.link_en = ex.link_en;
    assign ctrl.alu_op  = ex.alu_op;
    assign ctrl.pc_sel  = ex.pc_sel;
    assign ctrl.op1_sel = id.op1_sel;
    assign ctrl.op2_sel = id.op2_sel;

endmodule
