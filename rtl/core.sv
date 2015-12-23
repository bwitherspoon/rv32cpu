/*
 * core.sv
 */

import riscv::*;

/**
 * Module: core
 *
 */
module core (
    input  logic  clk,
    input  logic  reset,
    output logic [3:0] led
);
    wire resetn = ~reset;

    // Control signals
    opcode_t opcode;
    funct3_t funct3;
    funct7_t funct7;
    logic eq;
    logic lt;
    logic ltu;
    ctrl_t ctrl;

    // Local memory signals
    word_t dmem_rdata;
    word_t imem_rdata;

    // Register file signals
    addr_t rs1_addr;
    addr_t rs2_addr;
    word_t rs1_data;
    word_t rs2_data;

    // Fetch signals
    word_t pc = riscv::TEXT_ADDR;

    // Decode signals
    imm_t i_imm;
    imm_t s_imm;
    imm_t b_imm;
    imm_t u_imm;
    imm_t j_imm;
    word_t op1;
    word_t op2;
    addr_t rd;

    // Execute signals
    word_t alu_out;

    // Writeback signals
    word_t rd_data;
    word_t rd_addr;

    // Pipeline signals
    struct packed {
        word_t pc;
        inst_t ir;
    } id;

    struct packed {
        word_t pc;
        word_t op1;
        word_t op2;
        word_t rs1_data;
        word_t rs2_data;
        addr_t rd_addr;
    } ex;

    struct packed {
        word_t rs2_data;
        addr_t rd_addr;
        word_t ex_data;
    } mem;

    struct packed {
        addr_t rd_addr;
        word_t ex_data;
    } wb;

    // Control
    control control (.invalid(), .*);

    // Local memory
    memory memory (
        .dmem_op(ctrl.mem_op),
        .dmem_addr(mem.ex_data),
        .dmem_wdata(mem.rs2_data),
        .dmem_error(),
        .imem_addr(pc),
        .imem_error(),
        .*
    );

    // Register file
    regfile regfile (
        .rd_en(ctrl.reg_en),
        .rd_addr(wb.rd_addr),
        .*
    );

    // Simple memory mapped external IO
    always_ff @(posedge clk)
        if (~resetn)
            led <= '0;
        else if (ctrl.mem_op == STORE_WORD && | mem.ex_data[31:12])
            led <= mem.rs2_data[3:0];
        else
            led <= led;

    /*
     * Fetch
     */

    always_ff @(posedge clk)
        if (~resetn)
            pc <= riscv::TEXT_ADDR;
        else
            unique case (ctrl.pc_sel)
                riscv::PC_ADDR: pc <= alu_out;
                riscv::PC_TRAP: pc <= riscv::TRAP_ADDR;
                riscv::PC_NEXT: pc <= pc + 4;
            endcase

    assign id.ir = imem_rdata;

    always_ff @(posedge clk)
        id.pc <= pc;

    /*
     * Decode
     */

    // Immediate sign extension
    assign i_imm = signed'(id.ir.i.imm_11_0);
    assign s_imm = signed'({id.ir.s.imm_11_5, id.ir.s.imm_4_0});
    assign b_imm = signed'({id.ir.sb.imm_12, id.ir.sb.imm_11, id.ir.sb.imm_10_5, id.ir.sb.imm_4_1, 1'b0});
    assign u_imm = signed'({id.ir.u.imm_31_12, 12'd0});
    assign j_imm = signed'({id.ir.uj.imm_20, id.ir.uj.imm_19_12, id.ir.uj.imm_11, id.ir.uj.imm_10_1, 1'b0});

    // Register addresses
    assign rs1_addr = id.ir.r.rs1;
    assign rs2_addr = id.ir.r.rs2;
    assign rd_addr  = id.ir.r.rd;

    // Control signals
    assign opcode = id.ir.r.opcode;
    assign funct3 = id.ir.r.funct3;
    assign funct7 = id.ir.r.funct7;

    // First operand mux
    always_comb
        unique case (ctrl.op1_sel)
            OP1_RS1: op1 = rs1_data;
            OP1_PC:  op1 = id.pc;
            default: op1 = 'x;
        endcase

    // Second operand mux
    always_comb
        unique case (ctrl.op2_sel)
            OP2_RS2:   op2 = rs2_data;
            OP2_I_IMM: op2 = i_imm;
            OP2_S_IMM: op2 = s_imm;
            OP2_B_IMM: op2 = b_imm;
            OP2_U_IMM: op2 = u_imm;
            OP2_J_IMM: op2 = j_imm;
            default:   op2 = 'x;
        endcase

    always_ff @(posedge clk) begin
        ex.pc       <= id.pc;
        ex.op1      <= op1;
        ex.op2      <= op2;
        ex.rs1_data <= rs1_data;
        ex.rs2_data <= rs2_data;
        ex.rd_addr  <= rd_addr;
    end

    /*
     * Execute
     */

    // Comparators
    assign eq  = ex.rs1_data == ex.rs2_data;
    assign lt  = signed'(ex.rs1_data) < signed'(ex.rs2_data);
    assign ltu = ex.rs1_data < ex.rs2_data;

    alu alu (
        .opcode(ctrl.alu_op),
        .op1(ex.op1),
        .op2(ex.op2),
        .out(alu_out)
    );

    always_ff @(posedge clk) begin
        mem.rs2_data <= ex.rs2_data;
        mem.rd_addr  <= ex.rd_addr;
        mem.ex_data <= (ctrl.link_en) ? ex.pc + 4 : alu_out;
    end

    /*
     * Memory
     */
    always_ff @(posedge clk) begin
        wb.rd_addr  <= mem.rd_addr;
        wb.ex_data  <= mem.ex_data;
    end

    /*
     * Writeback
     */
    assign rd_data = (ctrl.load_en) ? dmem_rdata : wb.ex_data;

endmodule
