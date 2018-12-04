/*
 * Copyright 2015-2018 C. Brett Witherspoon
 *
 * See LICENSE for more details.
 */

/**
 * Module: fetch
 *
 * Instruction fetch module.
 */
 module fetch
    import rv32::id_t;
    import rv32::inst_t;
    import rv32::word_t;
(
    input  logic  aclk,
    input  logic  aresetn,
    input  logic  branch,
    input  word_t target,
    input  logic  trap,
    input  word_t handler,
    input  logic  stall,
    axi.master    cache,
    axis.master   sink
);
    // Handshake signals
    wire raddr = cache.arvalid & cache.arready;
    wire rdata = cache.rvalid & cache.rready;
    wire tdata = sink.tvalid & sink.tready;

    // Internal signals
    id_t id;
    word_t pc;

    wire lock = sink.tvalid & ~sink.tready;

    // Fetch structure
    assign sink.tdata = id;

    // IR
    assign id.data.ir = cache.rdata;

    // PC
    assign id.data.pc = pc;

    always_ff @(posedge aclk)
        if (~aresetn)
            pc <= rv32::RESET_ADDR;
        else if (~lock)
            pc <= cache.araddr;

    // Trap
    logic trapped;

    always_ff @(posedge aclk)
        if (~aresetn)
            trapped <= '0;
        else if (trap)
            trapped <= '1;
        else if (cache.rvalid & cache.rready)
            trapped <= '0;

    // AXI
    always_ff @(posedge aclk)
        if (~aresetn)
            cache.arvalid <= '1;
        else if (trap | trapped | branch | ~stall)
            cache.arvalid <= '1;
        else if (cache.arvalid & cache.arready)
            cache.arvalid <= '0;

    always_ff @(posedge aclk)
        if (~aresetn)
            cache.araddr <= rv32::RESET_ADDR;
        else if (~(cache.arvalid & ~cache.arready))
            if (trap)
                cache.araddr <= handler;
            else if (trapped)
                cache.araddr <= cache.araddr + 4;
            else if (branch)
                cache.araddr <= target;
            else if (~stall)
                cache.araddr <= cache.araddr + 4;

    assign cache.arprot = axi4::AXI4;

    assign cache.rready = ~lock;

    assign sink.tvalid = cache.rvalid & ~branch & ~trapped;

endmodule : fetch
