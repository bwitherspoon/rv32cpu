/*
 * memory.sv
 */

import riscv::addr_t;
import riscv::data_t;
import riscv::reg_t;

/**
 * Module: memory
 */
module memory (
    input  logic  clk,
    input  logic  load,
    input  logic  store,
    input  data_t val,
    input  data_t rs2,
    input  reg_t  rd_mem,
    output reg_t  rd_wb,
    output data_t out
);

    data_t data;

    logic [7:0] mem [0:2**$bits(addr_t)-1];

    always_ff @(posedge clk)
        for (int i = 0; i < $bits(data_t)/8; i++) begin
            if (store)
                mem[addr_t'(val) + i] = rs2[8*i +: 8];
            data[8*i +: 8] = mem[addr_t'(val + i)];
        end

    assign out = (load) ? data : val;

    always_ff @(posedge clk)
        rd_wb <= rd_mem;

endmodule
