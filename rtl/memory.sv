/*
 * Copyright (c) 2015, 2016 C. Brett Witherspoon
 */

/**
 * Module: memory
 *
 * A memory controller. Data MUST be naturally aligned.
 */
module memory
    import core::addr_t;
    import core::op_t;
    import core::mm_t;
    import core::strb_t;
    import core::wb_t;
    import core::word_t;
(
    output word_t bypass,
    axi.master    cache,
    axis.slave    source,
    axis.master   sink
);
    /**
     * Module: reg2mem
     *
     * A function for register to memory alignment.
     */
    function void reg2mem(
        input  op_t   op,
        input  word_t addr,
        input  word_t din,
        output word_t dout,
        output strb_t strb
    );
        unique case (op)
            core::STORE_WORD: begin
                dout = din;
                strb = '1;
            end
            core::STORE_HALF: begin
                if (addr[1]) begin
                    dout = din << 16;
                    strb = 4'b1100;
                end else begin
                    dout = din;
                    strb = 4'b0011;
                end
            end
            core::STORE_BYTE:
                unique case (addr[1:0])
                    2'b00: begin
                        dout = din;
                        strb = 4'b0001;
                    end
                    2'b01: begin
                        dout = din << 8;
                        strb = 4'b0010;
                    end
                    2'b10: begin
                        dout = din << 16;
                        strb = 4'b0100;
                    end
                    2'b11: begin
                        dout = din << 24;
                        strb = 4'b1000;
                    end
                endcase
            default: begin
                dout = 'x;
                strb = '0;
            end
        endcase
    endfunction : reg2mem


///////////////////////////////////////////////////////////////////////////////

    /**
     * Function: mem2reg
     *
     * A function for memory to register alignment.
     */
    function void mem2reg(
        input  op_t   op,
        input  word_t addr,
        input  word_t din,
        output word_t dout
    );
        unique case (op)
            core::LOAD_WORD:
                dout = din;
            core::LOAD_HALF:
                if (addr[1]) dout = {{16{din[31]}}, din[31:16]};
                else         dout = {{16{din[15]}}, din[15:0]};
            core::LOAD_BYTE:
                unique case (addr[1:0])
                    2'b00: dout = {{24{din[7]}},  din[7:0]};
                    2'b01: dout = {{24{din[15]}}, din[15:8]};
                    2'b10: dout = {{24{din[23]}}, din[23:16]};
                    2'b11: dout = {{24{din[31]}}, din[31:24]};
                endcase
            core::LOAD_HALF_UNSIGNED:
                if (addr[1]) dout = {16'h0000, din[31:16]};
                else         dout = {16'h0000, din[15:0]};
            core::LOAD_BYTE_UNSIGNED:
                unique case (addr[1:0])
                    2'b00: dout = {24'h000000, din[7:0]};
                    2'b01: dout = {24'h000000, din[15:8]};
                    2'b10: dout = {24'h000000, din[23:16]};
                    2'b11: dout = {24'h000000, din[31:24]};
                endcase
            default:
                dout = 'x;
        endcase
    endfunction : mem2reg

///////////////////////////////////////////////////////////////////////////////

    /*
     * Cache write
     */

    strb_t wstrb;
    word_t wdata;

    always_comb
        reg2mem(
            .op(mm.ctrl.op),
            .addr(mm.data.alu),
            .din(mm.data.rs2),
            .strb(wstrb),
            .dout(wdata)
        );

    wire write = core::isstore(mm.ctrl.op) & source.tvalid;

    assign cache.awprot = axi4::AXI4;

    always_ff @(posedge cache.aclk)
        if (write & ~(cache.wvalid & ~cache.wready))
            cache.wdata <= wdata;

    always_ff @(posedge cache.aclk)
        if (write & ~(cache.wvalid & ~cache.wready))
            cache.wstrb <= wstrb;

    always_ff @(posedge cache.aclk)
        if (write & ~(cache.awvalid & ~cache.awready))
            cache.awaddr <= mm.data.alu;

    always_ff @(posedge cache.aclk)
        if (~cache.aresetn)
            cache.awvalid <= '0;
        else if (write)
            cache.awvalid <= '1;
        else if (cache.awvalid & cache.awready)
            cache.awvalid <= '0;

    always_ff @(posedge cache.aclk)
        if (~cache.aresetn)
            cache.wvalid <= '0;
        else if (write)
            cache.wvalid <= '1;
        else if (cache.wvalid & cache.wready)
            cache.wvalid <= '0;

    always_ff @(posedge cache.aclk)
        if (~cache.aresetn)
            cache.bready <= '0;
        else if (write)
            cache.bready <= '1;
        else if (cache.bvalid & cache.bready)
            cache.bready <= '0;

///////////////////////////////////////////////////////////////////////////////

    /*
     * Cache read
     */

    wire read = core::isload(mm.ctrl.op) & source.tvalid;

    assign cache.arprot = axi4::AXI4;

    always_ff @(posedge cache.aclk)
        if (~cache.aresetn)
            cache.arvalid <= '0;
        else if (read)
            cache.arvalid <= '1;
        else if (cache.arvalid & cache.arready)
            cache.arvalid <= '0;

    always_ff @(posedge cache.aclk)
        if (read & ~(cache.arvalid & ~cache.arready))
            cache.araddr <= mm.data.alu;

    always_ff @(posedge cache.aclk)
        if (~cache.aresetn)
            cache.rready <= '0;
        else if (read)
            cache.rready <= '1;
        else if (cache.rvalid & cache.rready)
            cache.rready <= '0;

///////////////////////////////////////////////////////////////////////////////

    /*
     * Streams
     */

    word_t rdata;

    mm_t mm;
    wb_t wb;

    assign mm = source.tdata;
    assign sink.tdata = wb;

    assign source.tready = sink.tready;

    always_ff @(posedge sink.aclk)
        if (~sink.aresetn)
            sink.tvalid <= '0;
        else if (source.tvalid)
            sink.tvalid <= '1;
        else if (sink.tvalid & sink.tready)
            sink.tvalid <= '0;

    always_comb
        mem2reg(
            .op(mm.ctrl.op),
            .addr(mm.data.alu),
            .din(cache.rdata),
            .dout(rdata)
        );

    assign bypass = core::isload(mm.ctrl.op) ? rdata : mm.data.alu;

    always_ff @(posedge sink.aclk)
        if (~sink.aresetn) begin
            wb.ctrl.op <= core::NULL;
        end else if (sink.tready) begin
            wb.ctrl.op <= (source.tvalid) ? mm.ctrl.op : core::NULL;
            wb.data.rd.data <= bypass;
            wb.data.rd.addr <= (source.tvalid) ? mm.data.rd : '0;
        end

endmodule : memory
