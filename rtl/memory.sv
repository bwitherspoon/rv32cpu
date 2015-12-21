/*
 * memory.sv
 */

import riscv::word_t;
import riscv::mem_op_t;

/**
 * Module: memory
 *
 * Local memory using Block RAM. Data MUST be naturally aligned.
 */
module memory (
    input  logic    clk,
    input  mem_op_t dmem_op,
    input  word_t   dmem_addr,
    input  word_t   dmem_wdata,
    output word_t   dmem_rdata,
    input  word_t   imem_addr,
    output word_t   imem_rdata,
    output logic    imem_error
);
    localparam ADDR_WIDTH = 10;

    // Block RAM
    logic       ram_ena;
    logic [3:0] ram_wea;
    word_t      ram_dia;
    word_t      ram_doa;

    assign ram_ena = dmem_op != riscv::NONE;

    ram #(
        .DATA_WIDTH($bits(word_t)),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) ram (
        .clk(clk),
        .ena(ram_ena),
        .wea(ram_wea),
        .addra(dmem_addr[ADDR_WIDTH+1:2]),
        .dia(ram_dia),
        .doa(ram_doa),
        .enb('1),
        .web('0),
        .addrb(imem_addr[ADDR_WIDTH+1:2]),
        .dib('0),
        .dob(imem_rdata)
    );

    // Misaligned instruction address
    assign imem_error = | imem_addr[1:0];

    // Data store operation
    always_comb
        unique case (dmem_op)
            riscv::STORE_WORD: begin
                ram_dia = dmem_wdata;
                ram_wea = '1;
            end
            riscv::STORE_HALF: begin
                if (dmem_addr[1]) begin
                    ram_dia = dmem_wdata << 16;
                    ram_wea = 4'b1100;
                end else begin
                    ram_dia = dmem_wdata;
                    ram_wea = 4'b0011;
                end
            end
            riscv::STORE_BYTE:
                unique case (dmem_addr[1:0])
                    2'b00: begin
                        ram_dia = dmem_wdata;
                        ram_wea = 4'b0001;
                    end
                    2'b01: begin
                        ram_dia = dmem_wdata << 8;
                        ram_wea = 4'b0010;
                    end
                    2'b10: begin
                        ram_dia = dmem_wdata << 16;
                        ram_wea = 4'b0100;
                    end
                    2'b11: begin
                        ram_dia = dmem_wdata << 24;
                        ram_wea = 4'b1000;
                    end
                endcase
            default: begin
                ram_dia = dmem_wdata;
                ram_wea = '0;
            end
        endcase

    // Data load operation
    always_comb
        unique case (dmem_op)
            riscv::LOAD_WORD:
                dmem_rdata = ram_doa;
            riscv::LOAD_HALF:
                if (dmem_addr[1])
                    dmem_rdata = {{16{ram_doa[31]}}, ram_doa[31:16]};
                else
                    dmem_rdata = {{16{ram_doa[15]}}, ram_doa[15:0]};
            riscv::LOAD_BYTE:
                unique case (dmem_addr[1:0])
                    2'b00: dmem_rdata = {{24{ram_doa[7]}},  ram_doa[7:0]};
                    2'b01: dmem_rdata = {{24{ram_doa[15]}}, ram_doa[15:8]};
                    2'b10: dmem_rdata = {{24{ram_doa[23]}}, ram_doa[23:16]};
                    2'b11: dmem_rdata = {{24{ram_doa[31]}}, ram_doa[31:24]};
                endcase
            riscv::LOAD_HALF_UNSIGNED:
                if (dmem_addr[1])
                    dmem_rdata = {16'h0000, ram_doa[31:16]};
                else
                    dmem_rdata = {16'h0000, ram_doa[15:0]};
            riscv::LOAD_BYTE_UNSIGNED:
                unique case (dmem_addr[1:0])
                    2'b00: dmem_rdata = {24'h000000, ram_doa[7:0]};
                    2'b01: dmem_rdata = {24'h000000, ram_doa[15:8]};
                    2'b10: dmem_rdata = {24'h000000, ram_doa[23:16]};
                    2'b11: dmem_rdata = {24'h000000, ram_doa[31:24]};
                endcase
            default:
                dmem_rdata = ram_doa;
        endcase
endmodule
