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
    axi.master    cache,
    axis.master   down
);
    // Handshake signals
    wire raddr = cache.arvalid & cache.arready;
    wire rdata = cache.rvalid & cache.rready;
    wire tdata = down.tvalid & down.tready;

    // Fetch structure
    id_t id;
    assign down.tdata  = id;

    // IR
    assign id.data.ir = cache.rdata;

    // PC and AXI
    always_ff @(posedge cache.aclk)
        if (~cache.aresetn) begin
            id.data.pc <= core::CODE_BASE;
            cache.araddr <= core::CODE_BASE;
        end else begin
            if (raddr & rdata) begin
                id.data.pc <= cache.araddr;
                if (trap)
                    cache.araddr <= handler;
                else if (branch)
                    cache.araddr <= target;
                else
                    cache.araddr <= cache.araddr + 4;
            end
        end

    assign cache.arprot = axi4::AXI4;

    always_ff @(posedge cache.aclk)
        if (~cache.aresetn)
            cache.arvalid <= '0;
        else
            cache.arvalid <= '1;

    always_ff @(posedge cache.aclk)
        if (~cache.aresetn)
            cache.rready <= '0;
        else if (raddr)
            cache.rready <= '1;
        else if (rdata)
            cache.rready <= '0;

    // Stream
    logic branched;

    always_ff @(posedge down.aclk)
        branched <= branch;

    logic tvalid;

    always_ff @(posedge down.aclk)
        if (~down.aresetn)
            tvalid <= '0;
        else if (rdata)
            tvalid <= '1;

    assign down.tvalid = (branch | branched) ? '0: tvalid;

endmodule : fetch
