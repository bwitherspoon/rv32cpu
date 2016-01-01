/*
 * Copyright (c) 2015, C. Brett Witherspoon
 */

`ifndef INIT_FILE
    `define INIT_FILE "boot.mem"
`endif

import riscv::word_t;
import riscv::mem_op_t;

/**
 * Module: memory
 *
 * Local memory using Block RAM. Data MUST be naturally aligned.
 */
module memory (
    input  logic    clk,
    input  logic    resetn,
    input  mem_op_t dmem_op,
    input  word_t   dmem_addr,
    input  word_t   dmem_wdata,
    output word_t   dmem_rdata,
    output logic    dmem_error,
    input  logic    imem_en,
    input  logic    imem_rst,
    input  word_t   imem_addr,
    output word_t   imem_rdata,
    output logic    imem_error
);

    localparam ADDR_WIDTH = 10;

    logic [3:0]               wea;
    logic [0:$bits(word_t)-1] dia; // Write little endian
    word_t                    doa;

    ram #(
        .WIDTH($bits(word_t)),
        .DEPTH(2**ADDR_WIDTH),
        .INIT_A(32'h00000000),
        .INIT_B(32'h00000013),
        .INIT_FILE(`INIT_FILE)
    ) ram (
        .clk,
        .rsta('0),
        .ena(~dmem_error),
        .wea,
        .addra(dmem_addr[ADDR_WIDTH+1:2]),
        .dia,
        .doa,
        .rstb(imem_rst),
        .enb(imem_en),
        .web('0),
        .addrb(imem_addr[ADDR_WIDTH+1:2]),
        .dib('0),
        .dob(imem_rdata)
    );

    // Misaligned and out of range memory access
    logic misaligned;
    logic out_of_range;

    always_comb begin : error
        unique case (dmem_op)
            riscv::STORE_WORD, riscv::LOAD_WORD: begin
                misaligned = |dmem_addr[1:0];
                out_of_range = |dmem_addr[$bits(dmem_addr)-1:ADDR_WIDTH+2];
            end
            riscv::STORE_HALF, riscv::LOAD_HALF, riscv::LOAD_HALF_UNSIGNED: begin
                misaligned = dmem_addr[0];
                out_of_range = |dmem_addr[$bits(dmem_addr)-1:ADDR_WIDTH+2];
            end
            default: begin
                misaligned = '0;
                out_of_range = '0;
            end
        endcase
    end : error

    assign dmem_error = out_of_range | misaligned;

    // Misaligned instruction address
    assign imem_error = |imem_addr[1:0];

    // Store
    always_comb begin : store
        unique case (dmem_op)
            riscv::STORE_WORD: begin
                dia = dmem_wdata;
                wea = '1;
            end
            riscv::STORE_HALF: begin
                if (dmem_addr[1]) begin
                    dia = dmem_wdata << 16;
                    wea = 4'b1100;
                end else begin
                    dia = dmem_wdata;
                    wea = 4'b0011;
                end
            end
            riscv::STORE_BYTE:
                unique case (dmem_addr[1:0])
                    2'b00: begin
                        dia = dmem_wdata;
                        wea = 4'b0001;
                    end
                    2'b01: begin
                        dia = dmem_wdata << 8;
                        wea = 4'b0010;
                    end
                    2'b10: begin
                        dia = dmem_wdata << 16;
                        wea = 4'b0100;
                    end
                    2'b11: begin
                        dia = dmem_wdata << 24;
                        wea = 4'b1000;
                    end
                endcase
            default: begin
                dia = dmem_wdata;
                wea = '0;
            end
        endcase
    end : store

    // Load
    mem_op_t    load_op;
    logic [1:0] load_addr;

    always_ff @(posedge clk) begin
        load_op   <= dmem_op;
        load_addr <= dmem_addr[1:0];
    end

    always_comb begin : load
        unique case (load_op)
            riscv::LOAD_HALF:
                if (load_addr[1])
                    dmem_rdata = {{16{doa[31]}}, doa[31:16]};
                else
                    dmem_rdata = {{16{doa[15]}}, doa[15:0]};
            riscv::LOAD_BYTE:
                unique case (load_addr)
                    2'b00: dmem_rdata = {{24{doa[7]}},  doa[7:0]};
                    2'b01: dmem_rdata = {{24{doa[15]}}, doa[15:8]};
                    2'b10: dmem_rdata = {{24{doa[23]}}, doa[23:16]};
                    2'b11: dmem_rdata = {{24{doa[31]}}, doa[31:24]};
                endcase
            riscv::LOAD_HALF_UNSIGNED:
                if (load_addr[1])
                    dmem_rdata = {16'h0000, doa[31:16]};
                else
                    dmem_rdata = {16'h0000, doa[15:0]};
            riscv::LOAD_BYTE_UNSIGNED:
                unique case (load_addr)
                    2'b00: dmem_rdata = {24'h000000, doa[7:0]};
                    2'b01: dmem_rdata = {24'h000000, doa[15:8]};
                    2'b10: dmem_rdata = {24'h000000, doa[23:16]};
                    2'b11: dmem_rdata = {24'h000000, doa[31:24]};
                endcase
            default:
                dmem_rdata = doa;
        endcase
    end : load

endmodule
