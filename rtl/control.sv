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
     input  opcode_t  opcode,
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
        unique case (opcode)
            opcodes::LOAD:      invalid = 'b1;
            opcodes::LOAD_FP:   invalid = 'b1;
            opcodes::CUSTOM_0:  invalid = 'b1;
            opcodes::MISC_MEM:  invalid = 'b1;
            opcodes::OP_IMM:    invalid = 'b1;
            opcodes::AUIPC:     invalid = 'b1;
            opcodes::OP_IMM_32: invalid = 'b1;
            opcodes::STORE:     invalid = 'b1;
            opcodes::STORE_FP:  invalid = 'b1;
            opcodes::CUSTOM_1:  invalid = 'b1;
            opcodes::AMO:       invalid = 'b1;
            opcodes::OP:        invalid = 'b1;
            opcodes::LUI:       invalid = 'b1;
            opcodes::OP_32:     invalid = 'b1;
            opcodes::MADD:      invalid = 'b1;
            opcodes::MSUB:      invalid = 'b1;
            opcodes::NMSUB:     invalid = 'b1;
            opcodes::NMADD:     invalid = 'b1;
            opcodes::OP_FP:     invalid = 'b1;
            opcodes::CUSTOM_2:  invalid = 'b1;
            opcodes::BRANCH:    invalid = 'b1;
            opcodes::JALR:      invalid = 'b1;
            opcodes::JAL:       invalid = 'b1;
            opcodes::SYSTEM:    invalid = 'b1;
            opcodes::CUSTOM_3:  invalid = 'b1;
            default:            invalid = 'b1;
        endcase

endmodule
