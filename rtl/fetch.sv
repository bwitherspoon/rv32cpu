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
    import core::id_t;
    import core::inst_t;
    import core::word_t;
(
    input  logic  clk,
    input  logic  reset,
    input  logic  branch,
    input  word_t target,
    input  logic  trap,
    input  word_t handler,
    axis.master   pipe,
    axi.master    code
);
    // Handshake signals
    wire addr = code.arvalid & code.arready;
    wire data = code.rvalid & code.rready;

    // Fetch structure
    id_t tdata;
    assign pipe.tdata = tdata;

    // IR
    assign tdata.data.ir = code.rdata;

    // PC
    word_t pc;
    assign tdata.data.pc = pc;

    always_ff @(posedge clk)
        if (reset) begin
            pc <= '0;
            code.araddr <= core::CODE_BASE;
        end else if (addr) begin
            pc <= code.araddr;
            if (trap)
                code.araddr <= handler;
            else if (branch)
                code.araddr <= target;
            else if (pipe.tready)
                code.araddr <= code.araddr + 4;
        end

    // AXI MM
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
            pipe.tvalid <= '0;
        else if (branch | trap | ~pipe.tready | ~code.arready)
            pipe.tvalid <= '0;
        else
            pipe.tvalid <= '1;

endmodule : fetch
