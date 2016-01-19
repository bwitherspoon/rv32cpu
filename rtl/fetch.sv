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
    input  logic  bubble,
    axi.master    cache,
    axis.master   down
);
    // Handshake signals
    wire raddr = cache.arvalid & cache.arready;
    wire rdata = cache.rvalid & cache.rready;

    // Fetch structure
    id_t id;
    assign down.tdata  = id;

    // IR
    assign id.data.ir = cache.rdata;

    // AXI stream
    wire tready = down.tready & ~bubble;

    assign down.tvalid = cache.rvalid;

    // PC
    always_ff @(posedge cache.aclk)
        if (~cache.aresetn)
            id.data.pc <= core::CODE_BASE;
        else
            if (raddr & tready)
                id.data.pc <= cache.araddr;

    // AXI
    always_ff @(posedge cache.aclk)
        if (~cache.aresetn)
            cache.araddr <= core::CODE_BASE;
        else
            if (raddr)
                if (trap)
                    cache.araddr <= handler;
                else if (branch)
                    cache.araddr <= target;
                else if (tready)
                    cache.araddr <= cache.araddr + 4;

    assign cache.arprot = axi4::AXI4;

    always_ff @(posedge cache.aclk)
        if (~cache.aresetn)
            cache.arvalid <= '0;
        else if (trap | branch | tready)
            cache.arvalid <= '1;
        else if (raddr)
            cache.arvalid <= '0;

    always_ff @(posedge cache.aclk)
        if (~cache.aresetn)
            cache.rready <= '0;
        else if (raddr)
            cache.rready <= '1;
        else if (rdata)
            cache.rready <= '0;

endmodule : fetch
