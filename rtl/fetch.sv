/*
 * Copyright 2015, 2016 C. Brett Witherspoon
 *
 * See LICENSE for more details.
 */

/**
 * Module: fetch
 *
 * Instruction fetch module.
 */
 module fetch
    import riscv::word_t;
    import riscv::inst_t;
(
    input  logic  clk,
    input  logic  reset,
    input  logic  branch,
    input  word_t target,
    input  logic  trap,
    input  word_t handler,
    input  logic  ready,
    output logic  valid,
    output word_t pc,
    output inst_t ir,
    axi.master    code
);
    wire addr = code.arvalid & code.arready;
    wire data = code.rvalid & code.rready;

    // PC
    always_ff @(posedge clk)
        if (reset) begin
            pc <= '0;
            code.araddr <= riscv::TEXT_BASE;
        end else if (addr) begin
            pc <= code.araddr;
            if (trap)
                code.araddr <= handler;
            else if (branch)
                code.araddr <= target;
            else if (ready)
                code.araddr <= code.araddr + 4;
        end

    // AXI
    assign code.arprot = axi4::AXI4;

    always_ff @(posedge clk)
        if (reset)
            code.arvalid <= '0;
        else
            code.arvalid <= '1;

    always_ff @(posedge clk)
        if (reset)
            code.rready <= '0;
        else if (addr)
            code.rready <= '1;
        else if (data)
            code.rready <= '0;

    // AXI Stream
    always_ff @(posedge clk)
        if (reset)
            valid <= '0;
        else if (branch | trap | ~ready | ~code.arready)
            valid <= '0;
        else
            valid <= '1;

    // IR
    assign ir = code.rdata;

    // Unused exceptions
    wire error = code.rready & code.rvalid & code.rresp != axi4::OKAY;
    wire align = |code.araddr[1:0];

endmodule : fetch
