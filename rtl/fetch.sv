/**
 * Module: fetch
 *
 * Instruction fetch stage
 */
module fetch (
    input  logic       clk,
    input  logic       resetn,
    input  logic       bubble,
    input  logic [1:0] pc_sel,
    input  riscv::pc_t jal_bxx_tgt,
    input  riscv::pc_t jalr_tgt,
    output riscv::pc_t pc,
    output riscv::ir_t ir
);

    imem imem (
        .clk(clk),
        .addr(),
        .data()
    );

endmodule
