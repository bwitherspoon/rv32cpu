/*
 * fetch.sv
 */

import riscv::WORD_WIDTH;
import riscv::ir_t;

/**
 * Module: fetch
 *
 * Instruction fetch stage
 */
module fetch (
    input  logic                  clk,
    input  logic                  resetn,
    input  logic                  bubble,
    input  logic [1:0]            pc_sel,
    input  logic [WORD_WIDTH-1:0] jal_bxx_tgt,
    input  logic [WORD_WIDTH-1:0] jalr_tgt,
    output logic [WORD_WIDTH-1:0] pc,
    output ir_t                   ir
);

    imem #(
        .ADDR_WIDTH(riscv::IMEM_ADDR_WIDTH),
        .DATA_WIDTH(riscv::IMEM_DATA_WIDTH)
    ) imem (
        .clk(clk),
        .addr(),
        .data()
    );

endmodule
