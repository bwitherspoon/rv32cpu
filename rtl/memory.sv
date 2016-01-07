/*  
 * Copyright (c) 2015, C. Brett Witherspoon
 */

/**
 * Module: memory
 *
 * Data MUST be naturally aligned.
 */
module memory
    import riscv::*;
#(
    ADDR_WIDTH = 10
)(
    input  logic    clk,
    input  logic    resetn,
    input  mem_op_t op,
    input  word_t   addr,
    input  word_t   din,
    output word_t   dout,
    output logic    strb,
    output logic    idle,
    axi.master      data
);
    typedef enum logic [1:0] { IDLE, ADDR, DATA, RESP } state_t;

    state_t wstate = IDLE;
    state_t wnext;

    state_t rstate = IDLE;
    state_t rnext;

    assign strb = rstate == RESP && rnext == IDLE;

    assign idle = (wstate == IDLE || wstate == RESP && wnext == IDLE) &&
                  (rstate == IDLE || rstate == RESP && rnext == IDLE);

    wire store = op == riscv::STORE_WORD || op == riscv::STORE_HALF ||
                 op == riscv::STORE_BYTE;

    wire load = op == riscv::LOAD_WORD || op == riscv::LOAD_HALF ||
                op == riscv::LOAD_BYTE || op == riscv::LOAD_HALF_UNSIGNED ||
                op == riscv::LOAD_BYTE_UNSIGNED;

    // FIXME Vivado synthesis grounds wdata and wstrb when initialized to zero
    logic awvalid;
    logic wvalid;
    word_t wdata;
    strb_t wstrb;
    logic bready;
    logic arvalid;
    logic rready;

    /*
     * Write
     */

    reg2mem reg2mem (.op, .addr, .din, .strb(wstrb), .dout(wdata));

    assign data.awprot = axi4::AXI4;

    // TODO reduce logic
    always_comb
        unique case (wstate)
            IDLE: begin
                awvalid = store;
                wvalid  = store;
                bready  = store;
                if (store) wnext = ADDR;
                else       wnext = IDLE;
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
            if (wstate == IDLE || wstate == RESP && wnext == IDLE) begin
                data.awaddr <= addr;
                data.wdata <= wdata;
                data.wstrb <= wstrb;
            end
        end

    /*
     * Read
     */

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
            if (rstate == IDLE || rstate == RESP && rnext == IDLE)
                data.araddr <= addr;
        end

    mem2reg mem2reg (
        .clk,
        .strb(rstate == IDLE || rnext == IDLE),
        .op,
        .addr,
        .din(data.rdata),
        .dout
    );

endmodule
