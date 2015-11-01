/*
 * control.sv
 */

import riscv::opcode_t;
import riscv::funct3_t;
import riscv::funct7_t;
import riscv::op1_sel_t;
import riscv::op2_sel_t;

/**
 * Module: control
 *
 * Control unit
 */
module control (
     input  logic     clk,
     input  opcode_t  op,
     input  funct3_t  funct3,
     input  funct7_t  funct7,
     output logic     invalid,
     output logic     bubble,
     output logic     kill,
     output logic     jump,
     output op1_sel_t op1_sel,
     output op1_sel_t op2_sel
);

    always_comb
        unique case (op)
            opcode::LOAD:      invalid = 'b1;
            opcode::LOAD_FP:   invalid = 'b1;
            opcode::CUSTOM_0:  invalid = 'b1;
            opcode::MISC_MEM:  invalid = 'b1;
            opcode::OP_IMM:    invalid = 'b1;
            opcode::AUIPC:     invalid = 'b1;
            opcode::OP_IMM_32: invalid = 'b1;
            opcode::STORE:     invalid = 'b1;
            opcode::STORE_FP:  invalid = 'b1;
            opcode::CUSTOM_1:  invalid = 'b1;
            opcode::AMO:       invalid = 'b1;
            opcode::OP:        invalid = 'b1;
            opcode::LUI:       invalid = 'b1;
            opcode::OP_32:     invalid = 'b1;
            opcode::MADD:      invalid = 'b1;
            opcode::MSUB:      invalid = 'b1;
            opcode::NMSUB:     invalid = 'b1;
            opcode::NMADD:     invalid = 'b1;
            opcode::OP_FP:     invalid = 'b1;
            opcode::CUSTOM_2:  invalid = 'b1;
            opcode::BRANCH:    invalid = 'b1;
            opcode::JALR:      invalid = 'b1;
            opcode::JAL:       invalid = 'b1;
            opcode::SYSTEM:    invalid = 'b1;
            opcode::CUSTOM_3:  invalid = 'b1;
            default:            invalid = 'b1;
        endcase

endmodule
