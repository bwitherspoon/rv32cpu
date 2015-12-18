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
     input logic    resetn,
     input  opcode_t opcode,
     input  funct3_t funct3,
     input  funct7_t funct7,
     input  logic    eq,
     input  logic    lt,
     input  logic    ltu,
     output ctrl_t   ctrl
);
    // Pipeline control signals
    ctrl_t ctrl_id = CTRL_NOP;

    struct packed {
        logic     load;
        logic     store;
        logic     write;
        logic     link;
        alu_t     alu_op;
        pc_sel_t  pc_sel;
    } ctrl_ex;

    struct packed {
        logic     load;
        logic     store;
        logic     write;
    } ctrl_mem;

    struct packed {
        logic     write;
    } ctrl_wb;

    // Decode stage registers
    always_comb
        unique case (opcode)
            OPCODE_OP_IMM:
                unique case (funct3)
                    FUNCT3_ADDI:
                        ctrl_id = CTRL_ADDI;
                    default:
                        ctrl_id = CTRL_INVALID;
                endcase
            OPCODE_OP:
                unique case (funct3)
                    FUNCT3_ADD_SUB:
                        ctrl_id = (funct7[5]) ? CTRL_ADD : CTRL_SUB;
                    default:
                        ctrl_id = CTRL_INVALID;
                endcase
            default:
                ctrl_id = CTRL_INVALID;
        endcase

    // Execute stage registers
    always_ff @(posedge clk)
        if (~resetn) begin
            ctrl_ex.load   <= 0;
            ctrl_ex.store  <= 0;
            ctrl_ex.write  <= 0;
            ctrl_ex.link   <= 0;
            ctrl_ex.alu_op <= ALU_ADD;
            ctrl_ex.pc_sel <= PC_PLUS4;
        end else begin
            ctrl_ex.load   <= ctrl_id.load;
            ctrl_ex.store  <= ctrl_id.store;
            ctrl_ex.write  <= ctrl_id.write;
            ctrl_ex.link   <= ctrl_id.link;
            ctrl_ex.alu_op <= ctrl_id.alu_op;
            ctrl_ex.pc_sel <= ctrl_id.pc_sel;
        end

    // Memory stage registers
    always_ff @(posedge clk)
        if (~resetn) begin
            ctrl_mem.load  <= 0;
            ctrl_mem.store <= 0;
            ctrl_mem.write <= 0;
        end else begin
            ctrl_mem.load  <= ctrl_ex.load;
            ctrl_mem.store <= ctrl_ex.store;
            ctrl_mem.write <= ctrl_ex.write;
        end

    // Writeback stage registers
    always_ff @(posedge clk) begin
        if (~resetn)
            ctrl_wb.write <= 0;
        else
            ctrl_wb.write <= ctrl_mem.write;
    end

    // Datapath control signals
    assign ctrl.load    = ctrl_mem.load;
    assign ctrl.store   = ctrl_mem.store;
    assign ctrl.write   = ctrl_wb.write;
    assign ctrl.link    = ctrl_ex.link;
    assign ctrl.alu_op  = ctrl_ex.alu_op;
    assign ctrl.pc_sel  = ctrl_ex.pc_sel;
    assign ctrl.op1_sel = ctrl_id.op1_sel;
    assign ctrl.op2_sel = ctrl_id.op2_sel;

endmodule
