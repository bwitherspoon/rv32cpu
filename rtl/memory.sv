/*  
 * Copyright (c) 2015, C. Brett Witherspoon
 */

/**
 * Module: reg2mem
 *
 * A private module for register to memory alignment.
 */
module reg2mem
    import core::fun_t;
    import core::word_t;
    import core::strb_t;
(
    input  fun_t       fun,
    input  word_t      addr,
    input  word_t      din,
    output word_t      dout,
    output strb_t      strb
);
    always_comb
        unique case (fun)
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
endmodule : reg2mem

/**
 * Module: mem2reg
 *
 * A private module for memory to register alignment.
 */
module mem2reg
    import core::fun_t;
    import core::word_t;
(
    input  fun_t       fun,
    input  logic [1:0] addr,
    input  word_t      din,
    output word_t      dout
);
    always_comb
        unique case (fun)
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
endmodule : mem2reg

/**
 * Module: memory
 *
 * Data MUST be naturally aligned.
 */
module memory
    import core::*;
#(
    ADDR_WIDTH = 10
)(
    input  logic    clk,
    input  logic    resetn,
    input  fun_t    fun,
    input  word_t   addr,
    input  word_t   din,
    output word_t   dout,
    output word_t   bypass,
    output logic    idle,
    axi.master      data
);
    typedef enum logic [1:0] { IDLE, ADDR, DATA, RESP } state_t;

    state_t wstate = IDLE;
    state_t wnext;

    state_t rstate = IDLE;
    state_t rnext;

    wire wstart = wstate == IDLE && wnext == ADDR;
    wire wstop  = wstate == RESP && wnext == IDLE;

    wire rstart = rstate == IDLE && rnext == ADDR;
    wire rstop  = rstate == RESP && rnext == IDLE;

    assign idle = wstate == IDLE && rstate == IDLE;

    wire range = ~|addr[$bits(addr)-1:$clog2(core::PERIPH_BASE)];
    wire store = core::is_store(fun) & range;
    wire load = core::is_load(fun) & range;

    /*
     * Write
     */

    // NOTE Vivado synthesis grounds wdata and wstrb when initialized to zero
    logic awvalid;
    logic wvalid;
    logic bready;
    word_t wdata;
    strb_t wstrb;

    reg2mem reg2mem (.fun, .addr, .din, .strb(wstrb), .dout(wdata));

    assign data.awprot = axi4::AXI4;

    // TODO reduce logic
    always_comb
        unique case (wstate)
            IDLE: begin
                if (store) wnext = ADDR;
                else       wnext = IDLE;
                awvalid = store;
                wvalid  = store;
                bready  = store;
            end
            ADDR: begin
                if (data.awready & data.wready & data.bvalid) begin
                    wnext   = IDLE;
                    awvalid = 1'b0;
                    wvalid  = 1'b0;
                    bready  = 1'b0;
                end else if (data.awready & data.wready) begin
                    wnext   = RESP;
                    awvalid = 1'b0;
                    wvalid  = 1'b0;
                    bready  = 1'b1;
                end else if (data.awready) begin
                    wnext   = DATA;
                    awvalid = 1'b0;
                    wvalid  = 1'b1;
                    bready  = 1'b1;
                end else begin
                    wnext   = ADDR;
                    awvalid = 1'b1;
                    wvalid  = 1'b1;
                    bready  = 1'b1;
                end
            end
            DATA: begin
                if (data.wready & data.bvalid) begin
                    wnext   = IDLE;
                    awvalid = 1'b0;
                    wvalid  = 1'b0;
                    bready  = 1'b0;
                end else if (data.wready) begin
                    wnext   = RESP;
                    awvalid = 1'b0;
                    wvalid  = 1'b0;
                    bready  = 1'b1;
                end else begin
                    wnext   = DATA;
                    awvalid = 1'b0;
                    wvalid  = 1'b1;
                    bready  = 1'b1;
                end
            end
            RESP: begin
                if (data.bvalid) begin
                    wnext   = IDLE;
                    awvalid = 1'b0;
                    wvalid  = 1'b0;
                    bready  = 1'b0;
                end else begin
                    wnext   = RESP;
                    awvalid = 1'b0;
                    wvalid  = 1'b0;
                    bready  = 1'b1;
                end
            end
        endcase

    always_ff @(posedge clk)
        if (~resetn) begin
            wstate <= IDLE;
            data.awvalid <= '0;
            data.wvalid <= '0;
            data.bready <= '0;
        end else begin
            wstate <= wnext;
            data.awvalid <= awvalid;
            data.wvalid <= wvalid;
            data.bready <= bready;
            if (wstart) begin
                data.awaddr <= addr;
                data.wdata <= wdata;
                data.wstrb <= wstrb;
            end
        end

    /*
     * Read
     */

    logic arvalid;
    logic rready;

    assign data.arprot = axi4::AXI4;

    // TODO reduce logic
    always_comb
        unique case (rstate)
            IDLE: begin
                if (load) rnext = ADDR;
                else      rnext = IDLE;
                arvalid = load;
                rready  = load;
            end
            ADDR: begin
                if (data.arready & data.rvalid) begin
                    rnext   = IDLE;
                    arvalid = 1'b0;
                    rready  = 1'b0;
                end else if (data.arready) begin
                    rnext   = RESP;
                    arvalid = 1'b0;
                    rready  = 1'b1;
                end else begin
                    rnext   = ADDR;
                    arvalid = 1'b1;
                    rready  = 1'b1;
                end
            end
            RESP: begin
                if (data.rvalid) begin
                    rnext   = IDLE;
                    arvalid = 1'b0;
                    rready  = 1'b0;
                end else begin
                    rnext   = RESP;
                    arvalid = 1'b0;
                    rready  = 1'b1;
                end
            end
        endcase

    always_ff @(posedge clk)
        if (~resetn) begin
            rstate <= IDLE;
            data.arvalid <= '0;
            data.rready <= '0;
        end else begin
            rstate <= rnext;
            data.arvalid <= arvalid;
            data.rready <= rready;
            if (rstart) begin
                data.araddr <= addr;
            end
        end

    fun_t rfun = core::NULL;
    logic [1:0] raddr = '0;

    always_ff @(posedge clk)
        if (rstart) begin
            rfun  <= fun;
            raddr <= addr[1:0];
        end

    mem2reg mem2reg (
        .fun(rfun),
        .addr(raddr),
        .din(data.rdata),
        .dout(bypass)
    );

    always_ff @(posedge clk)
        if (rstop)
            dout <= bypass;

endmodule : memory
