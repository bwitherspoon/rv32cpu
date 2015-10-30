/*
 * control.sv
 */

import riscv::opcode_t;
import riscv::funct3_t;
import riscv::funct7_t;
import riscv::target_t;

/**
 * Module: control
 *
 * Control unit
 */
module control (
     input  opcode_t opcode,
     input  funct3_t funct3,
     input  funct7_t funct7,
     output logic    bubble,
     output target_t target
);


endmodule
