/*
 * control.sv
 */

import riscv::opcode_t;
import riscv::funct3_t;
import riscv::funct7_t;
import control::op1_sel_t;
import control::op2_sel_t;
import control::ctrl_t;

/**
 * Module: controller
 *
 * Control unit
 */
module controller (
     input  logic     clk,
     input  opcode_t  opcode,
     input  funct3_t  funct3,
     input  funct7_t  funct7,
     output logic     invalid,
     output logic     bubble,
     output logic     jump,
     output logic     load,
     output logic     store,
     output logic     register,
     output op1_sel_t op1_sel,
     output op1_sel_t op2_sel
);

    ctrl_t id;

    always_comb
        unique case (opcode)
            opcodes::OP_IMM:
                unique case (funct3)
                    funct::ADDI:  id = control::ADDI;
                    funct::SLTI:  id = control::SLTI;
                    funct::SLTIU: id = control::SLTIU;
                    funct::ANDI:  id = control::ANDI;
                    funct::ORI:   id = control::ORI;
                    funct::XORI:  id = control::XORI;
                    default:      id = control::INVALID;
                endcase
            opcodes::AUIPC:
                id = control::AUIPC;
            default:
                id = control::INVALID;
        endcase

endmodule
