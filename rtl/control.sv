/*
 * control.sv
 */

import riscv::opcode_t;
import riscv::funct3_t;
import riscv::funct7_t;
import ctrl::op1_sel_t;
import ctrl::op2_sel_t;
import ctrl::ctrl_t;

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
                    funct::ADDI:  id = ctrl::ADDI;
                    funct::SLTI:  id = ctrl::SLTI;
                    funct::SLTIU: id = ctrl::SLTIU;
                    funct::ANDI:  id = ctrl::ANDI;
                    funct::ORI:   id = ctrl::ORI;
                    funct::XORI:  id = ctrl::XORI;
                    default:      id = ctrl::INVALID;
                endcase
            opcodes::AUIPC:
                id = ctrl::AUIPC;
            default:
                id = ctrl::INVALID;
        endcase

endmodule
