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
        input  op_t        op,
        input  logic [1:0] addr,
        input  word_t      din,
        output word_t      dout
    );
        unique case (op)
            core::LOAD_WORD:
                dout = din;
            core::LOAD_HALF:
                if (addr[1]) dout = {{16{din[31]}}, din[31:16]};
                else         dout = {{16{din[15]}}, din[15:0]};
            core::LOAD_BYTE:
                unique case (addr)
                    2'b00: dout = {{24{din[7]}},  din[7:0]};
                    2'b01: dout = {{24{din[15]}}, din[15:8]};
                    2'b10: dout = {{24{din[23]}}, din[23:16]};
                    2'b11: dout = {{24{din[31]}}, din[31:24]};
                endcase
            core::LOAD_HALF_UNSIGNED:
                if (addr[1]) dout = {16'h0000, din[31:16]};
                else         dout = {16'h0000, din[15:0]};
            core::LOAD_BYTE_UNSIGNED:
                unique case (addr)
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

    // Internal signals
    wire read = cache.rvalid & cache.rready;

    wire write = cache.bvalid & cache.bready;

    wire load = core::isload(mm.ctrl.op) & ~read & source.tvalid;

    wire store = core::isstore(mm.ctrl.op) & ~write & source.tvalid;

    /*
     * Cache write
     */

    always_comb
        reg2mem(
            .op(mm.ctrl.op),
            .addr(mm.data.alu),
            .din(mm.data.rs2),
            .strb(cache.wstrb),
            .dout(cache.wdata)
        );

    assign cache.awaddr = mm.data.alu;
    assign cache.awprot = axi4::AXI4;

    assign cache.awvalid = store;
    assign cache.wvalid = store;

    always_ff @(posedge cache.aclk)
        if (~cache.aresetn)
            cache.bready <= '0;
        else if (write)
            cache.bready <= '0;
        else if (store)
            cache.bready <= '1;

    /*
     * Cache read
     */

    assign cache.araddr = mm.data.alu;
    assign cache.arprot = axi4::AXI4;

    assign cache.arvalid = load;

    always_ff @(posedge cache.aclk)
        if (~cache.aresetn)
            cache.rready <= '0;
        else if (read)
            cache.rready <= '0;
        else if (load)
            cache.rready <= '1;

    /*
     * Stream
     */

    mm_t mm;
    wb_t wb;

    assign mm = source.tdata;
    assign sink.tdata = wb;

    assign source.tready = ~load & ~store;

    always_ff @(posedge sink.aclk)
        if (~sink.aresetn)
            sink.tvalid <= '0;
        else if (source.tvalid & source.tready)
            sink.tvalid <= '1;
        else if (sink.tvalid & sink.tready)
            sink.tvalid <= '0;

    word_t aligned;

    always_comb
        mem2reg(
            .op(mm.ctrl.op),
            .addr(cache.araddr[1:0]),
            .din(cache.rdata),
            .dout(aligned)
        );

    assign bypass = core::isload(mm.ctrl.op) ? aligned : mm.data.alu;

    always_ff @(posedge sink.aclk)
        if (~sink.aresetn) begin
            wb.ctrl.op <= core::NULL;
        end else if (sink.tready) begin
            wb.ctrl.op <= mm.ctrl.op;
            wb.data.rd.data <= bypass;
            wb.data.rd.addr <= mm.data.rd;
        end

endmodule : memory
