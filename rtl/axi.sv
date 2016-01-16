/*
 * Copyright 2016 C. Brett Witherspoon
 *
 * See LICENSE for more details.
 */

import axi4::prot_t;
import axi4::resp_t;

/**
 * Interface: axi
 */
interface axi #(
    ADDR_WIDTH = 32,
    DATA_WIDTH = 32
)(
    input logic aclk,
    input logic aresetn
);
    localparam STRB_WIDTH = DATA_WIDTH / 8;

    typedef logic [ADDR_WIDTH-1:0] addr_t;
    typedef logic [DATA_WIDTH-1:0] data_t;
    typedef logic [STRB_WIDTH-1:0] strb_t;

    // Write address channel
    addr_t awaddr = '0;
    prot_t awprot;
    logic  awvalid;
    logic  awready;

    // Write data channel
    data_t wdata;
    strb_t wstrb;
    logic  wvalid;
    logic  wready;

    // Write response channel
    resp_t bresp;
    logic  bvalid;
    logic  bready;

    // Read address channel
    addr_t araddr;
    prot_t arprot;
    logic  arvalid;
    logic  arready;

    // Read data channel
    data_t rdata;
    resp_t rresp;
    logic  rvalid;
    logic  rready;

    modport master (
        input  aclk,
        input  aresetn,

        output awaddr,
        output awprot,
        output awvalid,
        input  awready,

        output wdata,
        output wstrb,
        output wvalid,
        input  wready,

        input  bresp,
        input  bvalid,
        output bready,

        output araddr,
        output arprot,
        output arvalid,
        input  arready,

        input  rdata,
        input  rresp,
        input  rvalid,
        output rready
    );

    modport slave (
        input  aclk,
        input  aresetn,

        input  awaddr,
        input  awprot,
        input  awvalid,
        output awready,

        input  wdata,
        input  wstrb,
        input  wvalid,
        output wready,

        output bresp,
        output bvalid,
        input  bready,

        input  araddr,
        input  arprot,
        input  arvalid,
        output arready,

        output rdata,
        output rresp,
        output rvalid,
        input  rready
    );

`ifndef VERILATOR

    task automatic timeout(
        input string msg = "timeout",
        input int unsigned arg = 100
    );
        #arg $fatal(1, msg);
    endtask

    task automatic write(
        input addr_t addr,
        input data_t data,
        input strb_t strb = {STRB_WIDTH{1'b1}},
        input prot_t prot = axi4::AXI4
    );
        axi.master.awaddr  <= addr;
        axi.master.awprot  <= prot;
        axi.master.awvalid <= 1'b1;
        axi.master.wdata   <= data;
        axi.master.wstrb   <= strb;
        axi.master.wvalid  <= 1'b1;

        fork
            timeout("write timeout");
            wait(axi.master.bvalid & axi.master.bready) @(posedge aclk) axi.master.bready <= 1'b0;
        join_none

        fork
            wait(axi.master.awready) @(posedge aclk) axi.master.awvalid <= 1'b0;
            wait(axi.master.wready) @(posedge aclk) axi.master.wvalid <= 1'b0;
        join

        axi.master.bready <= 1'b1;

        disable timeout;
    endtask : write

    task automatic read(
        input  addr_t addr,
        output data_t data
     );
        axi.master.araddr <= addr;
        axi.master.arprot <= axi4::AXI4;
        axi.master.arvalid <= 1'b1;
        axi.master.rready <= 1'b1;

        fork
            timeout("read timeout");
        join_none

        wait(axi.master.arready) @(posedge aclk) axi.master.arvalid <= 1'b0;

        fork
            wait(axi.master.rvalid) @(posedge aclk) axi.master.rready <= 1'b0;
            wait(axi.master.rvalid) @(posedge aclk) data = axi.master.rdata;
        join


        disable timeout;
    endtask : read

`endif

endinterface : axi
