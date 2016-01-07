/*
 * Copyright 2016 C. Brett Witherspoon
 *
 * See LICENSE for more details.
 */

/**
 * Module: mem2reg
 */
module mem2reg
    import riscv::*;
(
    input  logic       clk,
    input  logic       strb,
    input  mem_op_t    op,
    input  word_t      addr,
    input  word_t      din,
    output word_t      dout
);
    mem_op_t    _op   = riscv::LOAD_STORE_NONE;
    logic [1:0] _addr = '0;

    always_ff @(posedge clk)
        if (strb) begin
            _op   <= op;
            _addr <= addr[1:0];
        end

    always_comb
        unique case (_op)
            riscv::LOAD_WORD:
                dout = din;
            riscv::LOAD_HALF:
                if (_addr[1]) dout = {{16{din[31]}}, din[31:16]};
                else          dout = {{16{din[15]}}, din[15:0]};
            riscv::LOAD_BYTE:
                unique case (_addr)
                    2'b00: dout = {{24{din[7]}},  din[7:0]};
                    2'b01: dout = {{24{din[15]}}, din[15:8]};
                    2'b10: dout = {{24{din[23]}}, din[23:16]};
                    2'b11: dout = {{24{din[31]}}, din[31:24]};
                endcase
            riscv::LOAD_HALF_UNSIGNED:
                if (_addr[1]) dout = {16'h0000, din[31:16]};
                else          dout = {16'h0000, din[15:0]};
            riscv::LOAD_BYTE_UNSIGNED:
                unique case (_addr)
                    2'b00: dout = {24'h000000, din[7:0]};
                    2'b01: dout = {24'h000000, din[15:8]};
                    2'b10: dout = {24'h000000, din[23:16]};
                    2'b11: dout = {24'h000000, din[31:24]};
                endcase
            default:
                dout = 'x;
        endcase

endmodule
