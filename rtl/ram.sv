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
    axi.slave data
);
    typedef logic [$bits(data.wdata)-1:0] data_t;

    wire waddr = data.awvalid & data.awready;
    wire wdata = data.wvalid & data.wready;
    wire wresp = data.bvalid & data.bready;
    wire raddr = data.arvalid & data.arready;
    wire rdata = data.rvalid & data.rready;

    wire [$clog2(DATA_DEPTH)-1:0] awaddr = data.awaddr[$clog2(DATA_DEPTH)-1+2:2];
    wire [$clog2(DATA_DEPTH)-1:0] araddr = data.araddr[$clog2(DATA_DEPTH)-1+2:2];

    logic [$clog2(RESP_DEPTH)-1:0] resp;

    bram #(
        .DATA_WIDTH($bits(data_t)),
        .DATA_DEPTH(DATA_DEPTH),
        .INIT_DATA_B(INIT_DATA),
        .INIT_FILE(INIT_FILE)
    ) bram (
        .clk(data.aclk),
        .rsta(1'b0),
        .ena(waddr & wdata),
        .wea(data.wstrb),
        .addra(awaddr),
        .dia(data.wdata),
        .doa(),
        .rstb(~data.aresetn),
        .enb(~data.aresetn | raddr),
        .web('0),
        .addrb(araddr),
        .dib('0),
        .dob(data.rdata)
    );

    // Write
    always_ff @(posedge data.aclk)
        if (~data.aresetn)                 resp <= '0;
        else if (waddr & wdata & ~wresp)   resp <= resp + 1;
        else if (~(waddr & wdata) & wresp) resp <= resp - 1;

    assign data.awready = ~&resp;
    assign data.wready = ~&resp;

    assign data.bresp = axi4::OKAY;
    assign data.bvalid = |resp;

    // Read
    always_ff @(posedge data.aclk)
        if (~data.aresetn)             data.arready <= '0;
        else if (rdata | ~data.rvalid) data.arready <= '1;

    always_ff @(posedge data.aclk)
        if (~data.aresetn) data.rvalid <= '0;
        else if (raddr)    data.rvalid <= '1;
        else if (rdata)    data.rvalid <= '0;

    assign data.rresp = axi4::OKAY;

endmodule
