/*
 * Copyright (c) 2016-2018 C. Brett Witherspoon
 */

`ifndef TEXT_FILE
    `define TEXT_FILE "boot.mem"
`endif

`ifndef DATA_FILE
    `define DATA_FILE ""
`endif

/**
 * Module: top
 */
module top #(
    parameter TEXT_FILE = `TEXT_FILE,
    parameter DATA_FILE = `DATA_FILE
)(
    input  logic        clk,
    input  logic        rst,
    input  logic        irq,

    output logic [31:0] m_axi_awaddr,
    output logic [ 2:0] m_axi_awprot,
    output logic        m_axi_awvalid,
    input  logic        m_axi_awready,

    output logic [31:0] m_axi_wdata,
    output logic [ 3:0] m_axi_wstrb,
    output logic        m_axi_wvalid,
    input  logic        m_axi_wready,

    input  logic [ 1:0] m_axi_bresp,
    input  logic        m_axi_bvalid,
    output logic        m_axi_bready,

    output logic [31:0] m_axi_araddr,
    output logic [ 2:0] m_axi_arprot,
    output logic        m_axi_arvalid,
    input  logic        m_axi_arready,

    input  logic [31:0] m_axi_rdata,
    input  logic [ 1:0] m_axi_rresp,
    input  logic        m_axi_rvalid,
    output logic        m_axi_rready
);
    wire aclk = clk;
    wire aresetn = ~rst;

    axi data(.*);
    axi code(.*);
    axi mmio(.*);

    assign m_axi_awaddr  = mmio.awaddr;
    assign m_axi_awprot  = mmio.awprot;
    assign m_axi_awvalid = mmio.awvalid;
    assign mmio.awready  = m_axi_awready;

    assign m_axi_wdata   = mmio.wdata;
    assign m_axi_wstrb   = mmio.wstrb;
    assign m_axi_wvalid  = mmio.wvalid;
    assign mmio.wready   = m_axi_wready;

    assign mmio.bresp    = axi4::resp_t'(m_axi_bresp);
    assign mmio.bvalid   = m_axi_bvalid;
    assign m_axi_bready  = mmio.bready;

    assign m_axi_araddr  = mmio.araddr;
    assign m_axi_arprot  = mmio.arprot;
    assign m_axi_arvalid = mmio.arvalid;
    assign mmio.arready  = m_axi_arready;

    assign mmio.rdata    = m_axi_rdata;
    assign mmio.rresp    = axi4::resp_t'(m_axi_rresp);
    assign mmio.rvalid   = m_axi_rvalid;
    assign m_axi_rready  = mmio.rready;

    ram #(
        .DATA_DEPTH(1024),
        .INIT_DATA(rv32::NOP),
        .INIT_FILE(TEXT_FILE)
    ) rom (.bus(code), .*);

    ram #(
        .DATA_DEPTH(1024),
        .INIT_FILE(DATA_FILE)
    ) ram (.bus(data), .*);

    cpu cpu (.data(data), .code(code), .mmio(mmio), .*);

endmodule
