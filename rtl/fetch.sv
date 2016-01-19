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
    input  logic  branch,
    input  word_t target,
    input  logic  trap,
    input  word_t handler,
    input  logic  flush,
    axi.master    cache,
    axis.master   down
);
    // Handshake signals
    wire raddr = cache.arvalid & cache.arready;
    wire rdata = cache.rvalid & cache.rready;
    wire tdata = down.tvalid & down.tready;

    // Fetch structure
    id_t id;
    assign down.tdata = id;

    // IR
    assign id.data.ir = cache.rdata;

    // PC
    always_ff @(posedge cache.aclk)
        if (~cache.aresetn)
            id.data.pc <= core::CODE_BASE;
        else if (down.tready)
            id.data.pc <= cache.araddr;

    // AXI stream
    assign down.tvalid = cache.rvalid & ~flush;

    // AXI
    assign cache.arprot = axi4::AXI4;

    always_ff @(posedge cache.aclk)
        if (~cache.aresetn)
            cache.araddr <= core::CODE_BASE;
        else if (down.tready)
            if (trap)
                cache.araddr <= handler;
            else if (branch)
                cache.araddr <= target;
            else
                cache.araddr <= cache.araddr + 4;

    always_ff @(posedge cache.aclk)
        if (~cache.aresetn)
            cache.arvalid <= '1;
        else if (down.tready)
            cache.arvalid = '1;
        else if (raddr)
            cache.arvalid = '0;

    assign cache.rready = down.tready;

endmodule : fetch
