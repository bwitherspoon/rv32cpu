/*
 * Copyright 2015, 2016 C. Brett Witherspoon
 *
 * See LICENSE for more details.
 */

/**
 * Module: ram
 */
module ram #(
    DATA_DEPTH = 1024,
    RESP_DEPTH = 4,
    INIT_DATA  = 32'h00000000,
    INIT_FILE  = ""
)(
    axi.slave bus
);
    typedef logic [$bits(bus.wdata)-1:0] data_t;

    // Handshake signals
    wire waddr = bus.awvalid & bus.awready;
    wire wdata = bus.wvalid & bus.wready;
    wire wresp = bus.bvalid & bus.bready;
    wire raddr = bus.arvalid & bus.arready;
    wire rdata = bus.rvalid & bus.rready;

    // Pending write responses
    logic [$clog2(RESP_DEPTH)-1:0] resp = '0;

    data_t nc;

    blockram #(
        .DATA_WIDTH($bits(data_t)),
        .DATA_DEPTH(DATA_DEPTH),
        .INIT_DATA_B(INIT_DATA),
        .INIT_FILE(INIT_FILE)
    ) blockram (
        .clk(bus.aclk),
        .rsta('0),
        .ena(waddr & wdata),
        .wea(bus.wstrb),
        .addra(bus.awaddr[$clog2(DATA_DEPTH)-1+2:2]),
        .dia(bus.wdata),
        .doa(nc),
        .rstb(~bus.aresetn),
        .enb(~bus.aresetn | raddr),
        .web('0),
        .addrb(bus.araddr[$clog2(DATA_DEPTH)-1+2:2]),
        .dib('0),
        .dob(bus.rdata)
    );

    // Write
    always_ff @(posedge bus.aclk)
        if (~bus.aresetn)
            resp <= '0;
        else if (waddr & wdata & ~wresp)
            resp <= resp + 1;
        else if (~(waddr & wdata) & wresp)
            resp <= resp - 1;

    assign bus.awready = ~&resp;
    assign bus.wready = ~&resp;

    assign bus.bresp = axi4::OKAY;
    assign bus.bvalid = |resp;

    // Read
    assign bus.arready = bus.rready;

    always_ff @(posedge bus.aclk)
        if (~bus.aresetn)
            bus.rvalid <= '0;
        else if (raddr)
            bus.rvalid <= '1;
        else if (rdata)
            bus.rvalid <= '0;

    assign bus.rresp = axi4::OKAY;

endmodule
