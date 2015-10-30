/**
 * Module: execute
 */
module execute (
    input  logic         clk,
    input  riscv::pc_t   pc,
    output riscv::word_t bypass_alu,
    output riscv::word_t out,
    output riscv::pc_t   jal_bxx_tgt,
    output riscv::pc_t   jalr_tgt
);

    alu alu (
        .funct(),
        .shamt(),
        .op1(),
        .op2(),
        .out()
    );

endmodule
