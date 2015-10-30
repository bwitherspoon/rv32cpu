/**
 * Module: control
 *
 * Control unit
 */
module control (
     input  riscv::opcode_t opcode,
     input  riscv::funct3_t funct3,
     input  riscv::funct7_t funct7,
     output logic           pc_wen,
     output logic [1:0]     pc_sel
);


endmodule
