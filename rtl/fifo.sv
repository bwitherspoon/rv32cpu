/**
 * Module: fifo
 * 
 * An AXI4-Stream FIFO.
 */
module fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 9
)(
    input logic clk,
    input logic resetn,
    axis.master read,
    axis.slave  write
);

    timeunit 1ns;
    timeprecision 1ps;
    
    // Internal registers
    logic [DATA_WIDTH-1:0] ram [0:2**ADDR_WIDTH-1];

    initial
        for (int i = 0; i < 2**ADDR_WIDTH; i++)
            ram[i] = '1;

    logic [ADDR_WIDTH:0] raddr = '0;
    logic [ADDR_WIDTH:0] waddr = '0;

    // Internal signals
    wire rhs = read.ready & read.valid;
    wire whs = write.ready & write.valid;

    wire empty = raddr == waddr;
    wire full  = raddr[ADDR_WIDTH] != waddr[ADDR_WIDTH] &&
                 raddr[ADDR_WIDTH-1:0] == waddr[ADDR_WIDTH-1:0];

    // Read logic
    always_ff @(posedge clk)
        if (~resetn)
            raddr <= '0;
        else if (rhs)
            raddr <= raddr + 1;

    always_ff @(posedge clk)
        read.tdata <= ram[raddr[ADDR_WIDTH-1:0]];

    always_ff @(posedge clk)
        read.tvalid <= ~empty;

    // Write logic
    always_ff @(posedge clk)
        if (~resetn)
            waddr <= '0;
        else if (whs)
            waddr <= waddr + 1;

    always_ff @(posedge clk)
        if (whs)
            ram[waddr[ADDR_WIDTH-1:0]] <= write.tdata;

    assign write.tready = resetn & ~full;

endmodule
