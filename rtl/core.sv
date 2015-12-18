/*
 * core.sv
 */

import riscv::*;

/**
 * Module: core
 *
 * The processor core.
 */
module core (
    input logic clk,
    input logic resetn
);

    opcode_t opcode;
    funct3_t funct3;
    funct7_t funct7;
    logic eq;
    logic lt;
    logic ltu;
    ctrl_t ctrl;
    pc_t target;
    pc_t pc_id;
    pc_t pc_ex;
    ir_t ir;
    data_t rdata1;
    data_t rdata2;
    reg_t raddr1;
    reg_t raddr2;
    data_t op1;
    data_t op2;
    data_t rs1;
    data_t rs2_ex;
    data_t rs2_mem;
    reg_t rd_ex;
    reg_t rd_mem;
    reg_t rd_wb;
    data_t val;
    data_t out;

    control control (
        .clk(clk),
        .resetn(resetn),
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .eq(eq),
        .lt(lt),
        .ltu(ltu),
        .ctrl(ctrl)
    );

    fetch fetch (
        .clk(clk),
        .resetn(resetn),
        .target(target),
        .pc_sel(ctrl.pc_sel),
        .pc(pc_id),
        .ir(ir)
    );

    decode decode (
        .clk(clk),
        .op1_sel(ctrl.op1_sel),
        .op2_sel(ctrl.op2_sel),
        .pc_id(pc_id),
        .ir(ir),
        .rdata1(rdata1),
        .rdata2(rdata2),
        .raddr1(raddr1),
        .raddr2(raddr2),
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .pc_ex(pc_ex),
        .op1(op1),
        .op2(op2),
        .rs1(rs1),
        .rs2(rs2_ex),
        .rd(rd_ex)
    );

    execute execute (
        .clk(clk),
        .alu_op(ctrl.alu_op),
        .link(ctrl.link),
        .pc(pc_ex),
        .op1(op1),
        .op2(op2),
        .rs1(rs1),
        .rs2_ex(rs2_ex),
        .rd_ex(rd_ex),
        .val(val),
        .target(target),
        .rs2_mem(rs2_mem),
        .rd_mem(rd_mem),
        .eq(eq),
        .lt(lt),
        .ltu(ltu)
    );

    memory memory (
        .clk(clk),
        .load(ctrl.load),
        .store(ctrl.store),
        .val(val),
        .rs2(rs2_mem),
        .rd_mem(rd_mem),
        .rd_wb(rd_wb),
        .out(out)
    );

    regfile regfile (
        .clk(clk),
        .raddr1(raddr1),
        .rdata1(rdata1),
        .raddr2(raddr2),
        .rdata2(rdata2),
        .wen(ctrl.write),
        .waddr(rd_wb),
        .wdata(out)
    );

endmodule
