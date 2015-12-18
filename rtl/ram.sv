/*
 * ram.sv
 */

import data::addr_t;
import data::data_t;

typedef logic [$bits(data_t)/8-1:0] en_t;

/**
 * Module: ram
 *
 * Byte addressable synchronous RAM
 */
module ram (
    input  logic  clk,
    input  en_t   wen,
    input  addr_t addr,
    input  data_t wdata,
    output data_t rdata
);

    logic [7:0] ram [0:2**$bits(addr_t)-1];

    always_ff @(posedge clk)
        for (int i = 0; i < $bits(data_t)/8; i++) begin
            if (wen[i])
                ram[addr + i] <= wdata[8*i +: 8];
            rdata[8*i +: 8] <= ram[addr + i];
        end

endmodule
