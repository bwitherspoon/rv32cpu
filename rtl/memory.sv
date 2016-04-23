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
    logic       aclk,
    logic       aresetn,
    axi.master  cache,
    axis.slave  source,
    axis.master sink
);
    /**
     * Function: reg2mem
     *
     * A helper function for register to memory alignment.
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
     * A helper function for memory to register alignment.
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
     * Internal signals
     */

    op_t op;
    word_t rdata;

    strb_t wstrb;
    word_t wdata;

    mm_t mm;
    wb_t wb;

    // Map interfaces to internal structures
    assign mm = source.tdata;

    assign sink.tdata = wb;

///////////////////////////////////////////////////////////////////////////////

    /*
     * Cache write
     */

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

    always_ff @(posedge aclk)
        if (write & ~(cache.awvalid & ~cache.awready))
            cache.awaddr <= mm.data.alu;

    always_ff @(posedge aclk)
        if (write & ~(cache.wvalid & ~cache.wready))
            cache.wdata <= wdata;

    always_ff @(posedge aclk)
        if (write & ~(cache.wvalid & ~cache.wready))
            cache.wstrb <= wstrb;

    always_ff @(posedge aclk)
        if (~cache.aresetn)
            cache.awvalid <= '0;
        else if (write)
            cache.awvalid <= '1;
        else if (cache.awvalid & cache.awready)
            cache.awvalid <= '0;

    always_ff @(posedge aclk)
        if (~cache.aresetn)
            cache.wvalid <= '0;
        else if (write)
            cache.wvalid <= '1;
        else if (cache.wvalid & cache.wready)
            cache.wvalid <= '0;

    always_ff @(posedge aclk)
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

    always_ff @(posedge aclk)
        if (~cache.aresetn)
            cache.arvalid <= '0;
        else if (read)
            cache.arvalid <= '1;
        else if (cache.arvalid & cache.arready)
            cache.arvalid <= '0;

    always_ff @(posedge aclk)
        if (read & ~(cache.arvalid & ~cache.arready))
            cache.araddr <= mm.data.alu;

    always_ff @(posedge aclk)
        if (read & ~(cache.arvalid & ~cache.arready))
            op <= mm.ctrl.op;

    assign cache.rready = sink.tready;

    always_comb
        mem2reg(
            .op(op),
            .addr(cache.araddr),
            .din(cache.rdata),
            .dout(rdata)
        );

///////////////////////////////////////////////////////////////////////////////

    /*
     * Register streams
     */

    assign source.tready = sink.tready;

    always_ff @(posedge aclk)
        if (~aresetn)
            sink.tvalid <= '0;
        else if (~read & ~write)
            sink.tvalid <= '1;
        else if (sink.tvalid & sink.tready)
            sink.tvalid <= '0;

    always_ff @(posedge aclk)
        if (~read & ~write) begin
            wb.ctrl.op      <= mm.ctrl.op;
            wb.data.rd.data <= mm.data.alu;
            wb.data.rd.addr <= mm.data.rd;
        end

endmodule : memory

