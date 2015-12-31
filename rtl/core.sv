/*
 * Copyright (c) 2015, C. Brett Witherspoon
 */

import riscv::*;

/**
 * Module: core
 */
module core (
    input  logic        clk,
    input  logic        resetn,
    output logic [15:0] gpio
);
    // Pipeline control and data signals
    struct packed {
        struct packed {
            rs_sel_t rs1_sel;
            rs_sel_t rs2_sel;
        } ctrl;
        struct packed {
            word_t pc;
            inst_t ir;
            word_t op1;
            word_t op2;
            word_t rs1_data;
            word_t rs2_data;
            word_t rd_addr;
        } data;
    } id;

    struct packed {
        struct packed {
            logic    reg_en;
            mem_op_t mem_op;
            pc_sel_t pc_sel;
            alu_op_t alu_op;
            jmp_op_t jmp_op;
            logic    jmp;
            logic    br;
            logic    load;
        } ctrl;
        struct packed {
            word_t pc;
            word_t op1;
            word_t op2;
            word_t rs1_data;
            word_t rs2_data;
            addr_t rd_addr;
            word_t alu_data;
        } data;
    } ex;

    struct packed {
        struct packed {
            logic    reg_en;
            mem_op_t mem_op;
            logic    jmp;
            logic    br;
            logic    load;
        } ctrl;
        struct packed {
            word_t rs2_data;
            addr_t rd_addr;
            word_t ex_data;
        } data;
    } mem;

    struct packed {
        struct packed {
            logic reg_en;
            logic load;
        } ctrl;
        struct packed {
            addr_t rd_addr;
            word_t rd_data;
            word_t ex_data;
        } data;
    } wb;

///////////////////////////////////////////////////////////////////////////////

    /*
     * Hazards
     */

    wire load = (ex.ctrl.load && id.data.rd_addr == ex.data.rd_addr && id.data.rd_addr != 0)
                || (mem.ctrl.load && ex.data.rd_addr == mem.data.rd_addr && ex.data.rd_addr != 0);

    wire flush = ex.ctrl.br | mem.ctrl.br | load;

    wire bubble = ctrl.jmp_op == JMP_OP_JAL | ex.ctrl.jmp;

    wire stall = bubble | load;

///////////////////////////////////////////////////////////////////////////////

    /*
     * Fetch
     */

    word_t pc = riscv::TEXT_ADDR;

    always_ff @(posedge clk)
        if (~resetn)
            pc <= riscv::TEXT_ADDR;
        else
            unique case (ex.ctrl.pc_sel)
                riscv::PC_ADDR: pc <= ex.data.alu_data;
                riscv::PC_TRAP: pc <= riscv::TRAP_ADDR;
                riscv::PC_NEXT: pc <= (stall) ? pc : pc + 4;
            endcase

    always_ff @(posedge clk)
        if (~stall)
            id.data.pc <= pc;

///////////////////////////////////////////////////////////////////////////////

    /*
     * Decode
     */

    opcode_t opcode;
    funct3_t funct3;
    funct7_t funct7;
    ctrl_t   ctrl;

    addr_t rs1_addr;
    addr_t rs2_addr;

    word_t rs1_data_mux;
    word_t rs2_data_mux;

    imm_t i_imm;
    imm_t s_imm;
    imm_t b_imm;
    imm_t u_imm;
    imm_t j_imm;

    // Control decoder
    control control (
        .opcode,
        .funct3,
        .funct7,
        .invalid(/* TODO */),
        .ctrl
    );

    // Register file
    regfile regfile (
        .clk,
        .rs1_addr,
        .rs2_addr,
        .rs1_data(id.data.rs1_data),
        .rs2_data(id.data.rs2_data),
        .rd_en(wb.ctrl.reg_en),
        .rd_addr(wb.data.rd_addr),
        .rd_data(wb.data.rd_data)
    );

    // Immediate sign extension
    assign i_imm = signed'(id.data.ir.i.imm_11_0);

    assign s_imm = signed'({id.data.ir.s.imm_11_5, id.data.ir.s.imm_4_0});

    assign b_imm = signed'({id.data.ir.sb.imm_12, id.data.ir.sb.imm_11,
                            id.data.ir.sb.imm_10_5, id.data.ir.sb.imm_4_1,
                            1'b0});

    assign u_imm = signed'({id.data.ir.u.imm_31_12, 12'd0});

    assign j_imm = signed'({id.data.ir.uj.imm_20, id.data.ir.uj.imm_19_12,
                            id.data.ir.uj.imm_11, id.data.ir.uj.imm_10_1,
                            1'b0});

    // Register addresses
    assign rs1_addr = id.data.ir.r.rs1;
    assign rs2_addr = id.data.ir.r.rs2;

    assign id.data.rd_addr  = id.data.ir.r.rd;

    // Control signals
    assign opcode = id.data.ir.r.opcode;
    assign funct3 = id.data.ir.r.funct3;
    assign funct7 = id.data.ir.r.funct7;

    // First source register mux
    always_comb
        unique case (id.ctrl.rs1_sel)
            RS_ALU: rs1_data_mux  = ex.data.alu_data;
            RS_MEM: rs1_data_mux  = mem.data.ex_data;
            default: rs1_data_mux = id.data.rs1_data;
        endcase

    // Second source register mux
    always_comb
        unique case (id.ctrl.rs2_sel)
            RS_ALU: rs2_data_mux  = ex.data.alu_data;
            RS_MEM: rs2_data_mux  = mem.data.ex_data;
            default: rs2_data_mux = id.data.rs2_data;
        endcase

    // First operand mux
    always_comb
        unique case (ctrl.op1_sel)
            OP1_PC:  id.data.op1 = id.data.pc;
            default: id.data.op1 = rs1_data_mux;
        endcase

    // Second operand mux
    always_comb
        unique case (ctrl.op2_sel)
            OP2_I_IMM: id.data.op2 = i_imm;
            OP2_S_IMM: id.data.op2 = s_imm;
            OP2_B_IMM: id.data.op2 = b_imm;
            OP2_U_IMM: id.data.op2 = u_imm;
            OP2_J_IMM: id.data.op2 = j_imm;
            default:   id.data.op2 = rs2_data_mux;
        endcase

    always_ff @(posedge clk) begin : decode
        if (~resetn) begin
            ex.ctrl.reg_en <= 1'b0;
            ex.ctrl.mem_op <= LOAD_STORE_NONE;
            ex.ctrl.jmp_op <= JMP_OP_NONE;
        end else begin
            ex.ctrl.reg_en   <= (flush) ? 1'b0 : ctrl.reg_en;
            ex.ctrl.mem_op   <= (flush) ? LOAD_STORE_NONE : ctrl.mem_op;
            ex.ctrl.alu_op   <= ctrl.alu_op;
            ex.ctrl.jmp_op   <= (flush) ? JMP_OP_NONE : ctrl.jmp_op;
            ex.data.pc       <= id.data.pc;
            ex.data.op1      <= id.data.op1;
            ex.data.op2      <= id.data.op2;
            ex.data.rs1_data <= rs1_data_mux;
            ex.data.rs2_data <= rs2_data_mux;
            ex.data.rd_addr  <= id.data.rd_addr;
        end
    end : decode

///////////////////////////////////////////////////////////////////////////////

    /* 
     * Forwarding
     */

    always_comb
        if (rs1_addr == ex.data.rd_addr && rs1_addr != '0 && ex.ctrl.reg_en == 1'b1)
        id.ctrl.rs1_sel = RS_ALU;
        else if (rs1_addr == mem.data.rd_addr && rs1_addr != '0 && mem.ctrl.reg_en == 1'b1 && mem.ctrl.mem_op == LOAD_STORE_NONE)
            id.ctrl.rs1_sel = RS_MEM;
        else
            id.ctrl.rs1_sel = RS_REG;

    always_comb
        if (rs2_addr == ex.data.rd_addr && rs2_addr != '0 && ex.ctrl.reg_en == 1'b1)
            id.ctrl.rs2_sel = RS_ALU;
        else if (rs2_addr == mem.data.rd_addr && rs2_addr != '0 && mem.ctrl.reg_en == 1'b1 && mem.ctrl.mem_op == LOAD_STORE_NONE)
            id.ctrl.rs2_sel = RS_MEM;
        else
            id.ctrl.rs2_sel = RS_REG;

///////////////////////////////////////////////////////////////////////////////

    /*
     * Execute
     */

    // Comparators
    wire eq  = ex.data.rs1_data == ex.data.rs2_data;
    wire lt  = signed'(ex.data.rs1_data) < signed'(ex.data.rs2_data);
    wire ltu = ex.data.rs1_data < ex.data.rs2_data;

    wire beq  = ex.ctrl.jmp_op == JMP_OP_BEQ  & eq;
    wire bne  = ex.ctrl.jmp_op == JMP_OP_BNE  & ~eq;
    wire blt  = ex.ctrl.jmp_op == JMP_OP_BLT  & lt;
    wire bltu = ex.ctrl.jmp_op == JMP_OP_BLTU & ltu;
    wire bge  = ex.ctrl.jmp_op == JMP_OP_BGE  & (eq | ~lt);
    wire bgeu = ex.ctrl.jmp_op == JMP_OP_BGEU & (eq | ~ltu);

    assign ex.ctrl.br     = beq | bne | blt | bltu | bge | bgeu;
    assign ex.ctrl.jmp    = ex.ctrl.jmp_op == JMP_OP_JAL;
    assign ex.ctrl.pc_sel = (ex.ctrl.jmp | ex.ctrl.br) ? PC_ADDR : PC_NEXT;

    wire link = ex.ctrl.jmp_op == JMP_OP_JAL;

    assign ex.ctrl.load = ex.ctrl.mem_op == LOAD_WORD ||
                          ex.ctrl.mem_op == LOAD_HALF ||
                          ex.ctrl.mem_op == LOAD_BYTE ||
                          ex.ctrl.mem_op == LOAD_HALF_UNSIGNED ||
                          ex.ctrl.mem_op == LOAD_BYTE_UNSIGNED;

    alu alu (
        .opcode(ex.ctrl.alu_op),
        .op1(ex.data.op1),
        .op2(ex.data.op2),
        .out(ex.data.alu_data)
    );

    always_ff @(posedge clk) begin : execute
        if (~resetn) begin
            mem.ctrl.reg_en <= 1'b0;
            mem.ctrl.mem_op <= LOAD_STORE_NONE;
            mem.ctrl.jmp    <= 1'b0;
            mem.ctrl.br     <= 1'b0;
        end else begin
            mem.ctrl.reg_en   <= ex.ctrl.reg_en;
            mem.ctrl.mem_op   <= ex.ctrl.mem_op;
            mem.ctrl.jmp      <= ex.ctrl.jmp;
            mem.ctrl.br       <= ex.ctrl.br;
            mem.data.rs2_data <= ex.data.rs2_data;
            mem.data.rd_addr  <= ex.data.rd_addr;
            mem.data.ex_data  <= (link) ? ex.data.pc + 4 : ex.data.alu_data;
        end
    end : execute

///////////////////////////////////////////////////////////////////////////////

    /*
     * Memory
     */

    word_t mem_data;

    memory memory (
        .clk,
        .resetn,
        .dmem_op(mem.ctrl.mem_op),
        .dmem_addr(mem.data.ex_data),
        .dmem_wdata(mem.data.rs2_data),
        .dmem_rdata(mem_data),
        .dmem_error(/* TODO */),
        .imem_en(~(stall & ~bubble)),
        .imem_rst(bubble),
        .imem_addr(pc),
        .imem_rdata(id.data.ir),
        .imem_error(/* TODO */)
    );

    assign mem.ctrl.load = mem.ctrl.mem_op == LOAD_WORD ||
                           mem.ctrl.mem_op == LOAD_HALF ||
                           mem.ctrl.mem_op == LOAD_BYTE ||
                           mem.ctrl.mem_op == LOAD_HALF_UNSIGNED ||
                           mem.ctrl.mem_op == LOAD_BYTE_UNSIGNED;

    always_ff @(posedge clk) begin : writeback
        if (~resetn)
            wb.ctrl.reg_en <= 1'b0;
        else begin
            wb.ctrl.reg_en  <= mem.ctrl.reg_en;
            wb.ctrl.load    <= mem.ctrl.load;
            wb.data.rd_addr <= mem.data.rd_addr;
            wb.data.ex_data <= mem.data.ex_data;
        end
    end : writeback

    // Crude memory mapped external IO
    always_ff @(posedge clk)
        if (~resetn)
            gpio <= '0;
        else if (mem.ctrl.mem_op == STORE_WORD && |mem.data.ex_data[31:12])
            gpio <= mem.data.rs2_data[15:0];

///////////////////////////////////////////////////////////////////////////////

    /*
     * Writeback
     */

    assign wb.data.rd_data = (wb.ctrl.load) ? mem_data : wb.data.ex_data;

endmodule
