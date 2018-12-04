/*
 * Copyright (c) 2016-2018 C. Brett Witherspoon
 */

/**
 * Module: arbitrate
 *
 * Memory translate and multiplexing.
 */
module arbitrate (
    output logic fault,
    axi.slave  cache,
    axi.master code,
    axi.master data,
    axi.master mmio
);

    typedef enum logic [1:0] { NONE, CODE, DATA, MMIO } request_t;

    request_t read;
    request_t write;

    // Write state
    wire wcode = cache.awaddr >= rv32::CODE_BASE && cache.awaddr < rv32::CODE_BASE + rv32::CODE_SIZE;
    wire wdata = cache.awaddr >= rv32::DATA_BASE && cache.awaddr < rv32::DATA_BASE + rv32::DATA_SIZE;
    wire wmmio = cache.awaddr >= rv32::MMIO_BASE;

    always_comb
        if (wcode)      write = CODE;
        else if (wdata) write = DATA;
        else if (wmmio) write = MMIO;
        else            write = NONE;

    // Read state
    wire rcode = cache.araddr >= rv32::CODE_BASE && cache.araddr < rv32::CODE_BASE + rv32::CODE_SIZE;
    wire rdata = cache.araddr >= rv32::DATA_BASE && cache.araddr < rv32::DATA_BASE + rv32::DATA_SIZE;
    wire rmmio = cache.araddr >= rv32::MMIO_BASE;

    always_comb
        if (rcode)      read = CODE;
        else if (rdata) read = DATA;
        else if (rmmio) read = MMIO;
        else            read = NONE;

    // Write address channel
    assign code.awaddr   = cache.awaddr;
    assign code.awprot   = cache.awprot;
    assign code.awvalid  = (write == CODE) ? cache.awvalid : '0;

    assign data.awaddr   = cache.awaddr;
    assign data.awprot   = cache.awprot;
    assign data.awvalid  = (write == DATA) ? cache.awvalid : '0;

    assign mmio.awaddr   = cache.awaddr;
    assign mmio.awprot   = cache.awprot;
    assign mmio.awvalid  = (write == MMIO) ? cache.awvalid : '0;

    always_comb begin : awready
        unique case (write)
            CODE:    cache.awready = code.awready;
            DATA:    cache.awready = data.awready;
            MMIO:    cache.awready = mmio.awready;
            default: cache.awready = '1;
        endcase
    end : awready

    // Write data channel
    assign code.wdata  = cache.wdata;
    assign code.wstrb  = cache.wstrb;
    assign code.wvalid = (write == CODE) ? cache.wvalid : '0;

    assign data.wdata  = cache.wdata;
    assign data.wstrb  = cache.wstrb;
    assign data.wvalid = (write == DATA) ? cache.wvalid : '0;

    assign mmio.wdata  = cache.wdata;
    assign mmio.wstrb  = cache.wstrb;
    assign mmio.wvalid = (write == MMIO) ? cache.wvalid : '0;

    always_comb begin : wready
        unique case (write)
            CODE:    cache.wready = code.wready;
            DATA:    cache.wready = data.wready;
            MMIO:    cache.wready = mmio.wready;
            default: cache.wready = '1;
        endcase
    end : wready

    // Write response channel
    always_comb begin : bresp
        unique case (write)
            CODE:    cache.bresp = code.bresp;
            DATA:    cache.bresp = data.bresp;
            MMIO:    cache.bresp = mmio.bresp;
            default: cache.bresp = axi4::DECERR;
        endcase
    end : bresp

    always_comb begin : bvalid
        unique case (write)
            CODE:    cache.bvalid = code.bvalid;
            DATA:    cache.bvalid = data.bvalid;
            MMIO:    cache.bvalid = mmio.bvalid;
            default: cache.bvalid = '1;
        endcase
    end : bvalid

    assign code.bready  = (write == CODE) ? cache.bready : '0;
    assign data.bready  = (write == DATA) ? cache.bready : '0;
    assign mmio.bready  = (write == MMIO) ? cache.bready : '0;

    // Address read channel
    assign data.araddr  = cache.araddr;
    assign data.arprot  = cache.arprot;
    assign data.araddr  = cache.araddr;
    assign data.arvalid = (read == DATA) ? cache.arvalid : '0;

    assign mmio.araddr  = cache.araddr;
    assign mmio.arprot  = cache.arprot;
    assign mmio.araddr  = cache.araddr;
    assign mmio.arvalid = (read == MMIO) ? cache.arvalid : '0;

    always_comb begin : arready
        unique case (read)
            DATA:    cache.arready = data.arready;
            MMIO:    cache.arready = mmio.arready;
            default: cache.arready = '1;
        endcase
    end : arready

    // Read data channel
    always_comb begin
        unique case (read)
            DATA:    cache.rdata = data.rdata;
            MMIO:    cache.rdata = mmio.rdata;
            default: cache.rdata = '0;
        endcase
    end

    always_comb begin : rresp
        unique case (read)
            DATA:    cache.rresp = data.rresp;
            MMIO:    cache.rresp = mmio.rresp;
            default: cache.rresp = axi4::DECERR;
        endcase
    end : rresp

    always_comb begin : rvalid
        unique case (read)
            DATA:    cache.rvalid = data.rvalid;
            MMIO:    cache.rvalid = mmio.rvalid;
            default: cache.rvalid = '1;
        endcase
    end : rvalid

    assign data.rready = (read == DATA) ? cache.rready : '0;
    assign mmio.rready = (read == MMIO) ? cache.rready : '0;

    // Faults
    assign fault = cache.arvalid & read == NONE;

endmodule : arbitrate
