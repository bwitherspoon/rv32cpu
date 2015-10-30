/**
 * Module: decode
 */
module decode (
    input  logic         clk,
    input  logic [1:0]   rs1_sel,
    input  logic [1:0]   rs2_sel,
    input  logic [2:0]   op2_sel,
    input  riscv::word_t bypass_alu,
    input  riscv::word_t bypass_mem,
    input  riscv::word_t bypass_wb,
    output riscv::word_t rs1,
    output riscv::wort_t rs2,
    output riscv::word_t op2
);

endmodule
