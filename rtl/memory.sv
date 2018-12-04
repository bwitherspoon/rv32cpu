/*
 * Copyright (c) 2015-2018 C. Brett Witherspoon
 */

/**
 * Module: memory
 *
 * A memory controller. Data MUST be naturally aligned.
 */
module memory
    import rv32::addr_t;
    import rv32::op_t;
    import rv32::mm_t;
    import rv32::strb_t;
    import rv32::wb_t;
    import rv32::word_t;
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
            rv32::STORE_WORD: begin
                dout = din;
                strb = '1;
            end
            rv32::STORE_HALF: begin
                if (addr[1]) begin
                    dout = din << 16;
                    strb = 4'b1100;
                end else begin
                    dout = din;
                    strb = 4'b0011;
                end
            end
            rv32::STORE_BYTE:
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
            rv32::LOAD_WORD:
                dout = din;
            rv32::LOAD_HALF:
                if (addr[1]) dout = {{16{din[31]}}, din[31:16]};
                else         dout = {{16{din[15]}}, din[15:0]};
            rv32::LOAD_BYTE:
                unique case (addr[1:0])
                    2'b00: dout = {{24{din[7]}},  din[7:0]};
                    2'b01: dout = {{24{din[15]}}, din[15:8]};
                    2'b10: dout = {{24{din[23]}}, din[23:16]};
                    2'b11: dout = {{24{din[31]}}, din[31:24]};
                endcase
            rv32::LOAD_HALF_UNSIGNED:
                if (addr[1]) dout = {16'h0000, din[31:16]};
                else         dout = {16'h0000, din[15:0]};
            rv32::LOAD_BYTE_UNSIGNED:
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

    addr_t rd;
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

    wire write = rv32::isstore(mm.ctrl.op) & source.tvalid & source.tready;

    wire writing = cache.bready;

    assign cache.awprot = axi4::AXI4;

    always_ff @(posedge aclk)
        if (write & ~(cache.awvalid & ~cache.awready)) begin
            cache.awaddr <= mm.data.alu;
            cache.wdata  <= wdata;
            cache.wstrb  <= wstrb;
        end

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

    wire read = rv32::isload(mm.ctrl.op) & source.tvalid & source.tready;

    logic reading = '0;

    always_ff @(posedge aclk)
        if (~cache.aresetn) begin
            reading <= '0;
        end else if (reading) begin
            if (cache.rvalid & cache.rready)
                reading <= '0;
        end else if (read) begin
                reading <= '1;
        end

    assign cache.arprot = axi4::AXI4;

    always_ff @(posedge aclk)
        if (~cache.aresetn)
            cache.arvalid <= '0;
        else if (read)
            cache.arvalid <= '1;
        else if (cache.arvalid & cache.arready)
            cache.arvalid <= '0;

    always_ff @(posedge aclk)
        if (read & ~(cache.arvalid & ~cache.arready)) begin
            cache.araddr <= mm.data.alu;
            op <= mm.ctrl.op;
            rd <= mm.data.rd;
        end

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
     * Register stream
     */

    assign source.tready = ~reading & ~writing & sink.tready;

    always_ff @(posedge aclk)
        if (~aresetn)
            sink.tvalid <= '0;
        else if (~read & ((source.tvalid & source.tready) | (cache.rvalid & cache.rready & cache.rresp == axi4::OKAY)))
            sink.tvalid <= '1;
        else if (sink.tvalid & sink.tready)
            sink.tvalid <= '0;

    always_ff @(posedge aclk)
        if (sink.tready) begin
            wb.ctrl.op      <= (cache.rvalid & cache.rready & cache.rresp == axi4::OKAY) ? op : mm.ctrl.op;
            wb.data.rd.data <= (cache.rvalid & cache.rready & cache.rresp == axi4::OKAY) ? rdata : mm.data.alu;
            wb.data.rd.addr <= (cache.rvalid & cache.rready & cache.rresp == axi4::OKAY) ? rd : mm.data.rd;
        end

endmodule : memory
