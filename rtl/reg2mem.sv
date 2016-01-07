/*
 * Copyright 2016 C. Brett Witherspoon
 *
 * See LICENSE for more details.
 */

/**
 * Module: reg2mem
 * 
 * Register to memory alignment
 */
module reg2mem
    import riscv::*;
(
    input  mem_op_t    op,
    input  word_t      addr,
    input  word_t      din,
    output strb_t      strb,
    output word_t      dout
);

    always_comb
        unique case (op)
            riscv::STORE_WORD: begin
                dout = din;
                strb = '1;
            end
            riscv::STORE_HALF: begin
                if (addr[1]) begin
                    dout = din << 16;
                    strb = 4'b1100;
                end else begin
                    dout = din;
                    strb = 4'b0011;
                end
            end
            riscv::STORE_BYTE:
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

endmodule
