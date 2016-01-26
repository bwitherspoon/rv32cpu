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
    axis.master   sink
);
    // Handshake signals
    wire raddr = cache.arvalid & cache.arready;
    wire rdata = cache.rvalid & cache.rready;
    wire tdata = sink.tvalid & sink.tready;

    // Fetch structure
    id_t id;
    assign sink.tdata = id;

    // IR
    assign id.data.ir = cache.rdata;

    // PC
    word_t pc;
    assign id.data.pc = pc;

    always_ff @(posedge cache.aclk)
        if (~cache.aresetn)
            pc <= core::CODE_BASE;
        else if (cache.arready & sink.tready)
            pc <= cache.araddr;

    // AXI
    always_ff @(posedge cache.aclk)
        if (~cache.aresetn)
            cache.araddr <= core::CODE_BASE;
        else if (cache.arready)
            if (trap)
                cache.araddr <= handler;
            else if (branch)
                cache.araddr <= target;
            else if (sink.tready)
                cache.araddr <= cache.araddr + 4;

    assign cache.arprot = axi4::AXI4;

    always_ff @(posedge cache.aclk)
        if (~cache.aresetn)
            cache.arvalid <= '1;
        else if (~bubble)
            cache.arvalid <= '1;
        else if (raddr)
            cache.arvalid <= '0;

    assign cache.rready = sink.tready;

    always_ff @(posedge sink.aclk)
        if (~sink.aresetn)
            sink.tvalid <= '0;
        else if (~bubble & ~branch)
            sink.tvalid <= '1;
        else if (tdata)
            sink.tvalid <= '0;


endmodule : fetch
