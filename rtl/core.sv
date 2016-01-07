/*
 * Copyright (c) 2015, 2016 C. Brett Witherspoon
 */

/**
 * Module: core
 */
module core
    import riscv::*;
(
    input  logic clk,
    input  logic reset,
    input  logic interrupt,
    axi.master   code,
    axi.master   data,
    axi.master   peripheral
);
    wire resetn = ~reset;

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
            addr_t reg_addr;
            addr_t rs1_addr;
            addr_t rs2_addr;
            word_t rs1_data;
            word_t rs2_data;
        } data;
    } id;

    struct packed {
        struct packed {
            logic    reg_en;
            mem_op_t mem_op;
            alu_op_t alu_op;
            jmp_op_t jmp_op;
            logic    jump;
            logic    branch;
            logic    load;
            logic    store;
        } ctrl;
        struct packed {
            word_t pc;
            word_t op1;
            word_t op2;
            word_t rs1_data;
            word_t rs2_data;
            addr_t reg_addr;
            word_t alu_data;
        } data;
    } ex;

    struct packed {
        struct packed {
            logic    reg_en;
            mem_op_t mem_op;
            logic    load;
            logic    store;
        } ctrl;
        struct packed {
            addr_t reg_addr;
            word_t alu_data;
            word_t mem_data;
        } data;
    } mem;

    struct packed {
        struct packed {
            logic reg_en;
            logic load;
        } ctrl;
        struct packed {
            addr_t reg_addr;
            word_t reg_data;
            word_t alu_data;
            word_t mem_data;
        } data;
    } wb;

///////////////////////////////////////////////////////////////////////////////

    /*
     * Exceptions / Traps / Interrupts
     */

    wire invalid;

    wire trap = ~reset & interrupt;


///////////////////////////////////////////////////////////////////////////////

    /*
     * Hazards
     */

    // TODO store -> load

    wire branch = ex.ctrl.branch | ex.ctrl.jump;

    // Bubble after jump to wait for address
    wire jump = ctrl.jmp_op == JMP_OP_JAL;

    // Bubble after load to account for load latency
    wire load = riscv::is_load(ctrl.mem_op);

    // A bubble prevents the PC from advancing and inserts NOPs
    wire bubble = load | jump;

    wire idle;

    // A stall locks the entier pipeline and bubbles
    wire stall = ~idle;

///////////////////////////////////////////////////////////////////////////////

    /*
     * Forwarding
     */

    // FIXME clean up this mess
    always_comb
        if (id.data.rs1_addr == ex.data.reg_addr
            && id.data.rs1_addr != '0
            && ex.ctrl.reg_en == '1
            && ex.ctrl.mem_op == LOAD_STORE_NONE)
            id.ctrl.rs1_sel = RS_ALU;
        else if (id.data.rs1_addr == mem.data.reg_addr
                 && id.data.rs1_addr != '0
                 && mem.ctrl.reg_en == '1
                 && mem.ctrl.mem_op == LOAD_STORE_NONE)
            id.ctrl.rs1_sel = RS_MEM;
        else if (id.data.rs1_addr == mem.data.reg_addr
                 && id.data.rs1_addr != '0
                 && mem.ctrl.reg_en == '1
                 && mem.ctrl.load == '1)
            id.ctrl.rs1_sel = RS_RAM;
        else
            id.ctrl.rs1_sel = RS_REG;

    always_comb
        if (id.data.rs2_addr == ex.data.reg_addr
            && id.data.rs2_addr != '0
            && ex.ctrl.reg_en == '1
            && ex.ctrl.mem_op == LOAD_STORE_NONE)
            id.ctrl.rs2_sel = RS_ALU;
        else if (id.data.rs2_addr == mem.data.reg_addr
                 && id.data.rs2_addr != '0
                 && mem.ctrl.reg_en == '1
                 && mem.ctrl.mem_op == LOAD_STORE_NONE)
            id.ctrl.rs2_sel = RS_MEM;
        else if (id.data.rs2_addr == mem.data.reg_addr
                 && id.data.rs2_addr != '0
                 && mem.ctrl.reg_en == '1
                 && mem.ctrl.load == '1)
            id.ctrl.rs2_sel = RS_RAM;
        else
            id.ctrl.rs2_sel = RS_REG;

///////////////////////////////////////////////////////////////////////////////

    /*
     * Fetch
     */

    word_t target;

    logic valid;

    // stall, load, jump
    wire ready = ~stall & ~bubble;

    fetch fetch (
        .clk,
        .reset(~resetn),
        .branch,
        .target,
        .trap,
        .handler(TRAP_BASE),
        .ready,
        .pc(id.data.pc),
        .ir(id.data.ir),
        .valid,
        .code(code)
    );

///////////////////////////////////////////////////////////////////////////////

    /*
     * Decode
     */

    opcode_t opcode;
    funct3_t funct3;
    funct7_t funct7;
    ctrl_t   ctrl;

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
        .valid,
        .invalid,
        .ctrl
    );

    // Register file
    regfile regfile (
        .clk,
        .rs1_addr(id.data.rs1_addr),
        .rs2_addr(id.data.rs2_addr),
        .rs1_data(id.data.rs1_data),
        .rs2_data(id.data.rs2_data),
        .rd_en(wb.ctrl.reg_en),
        .rd_addr(wb.data.reg_addr),
        .rd_data(wb.data.reg_data)
    );

    // Immediate sign extension
    assign i_imm = imm_t'(signed'(id.data.ir.i.imm_11_0));

    assign s_imm = imm_t'(signed'({id.data.ir.s.imm_11_5, id.data.ir.s.imm_4_0}));

    assign b_imm = imm_t'(signed'({id.data.ir.sb.imm_12, id.data.ir.sb.imm_11, id.data.ir.sb.imm_10_5, id.data.ir.sb.imm_4_1, 1'b0}));

    assign u_imm = (signed'({id.data.ir.u.imm_31_12, 12'd0}));

    assign j_imm = imm_t'(signed'({id.data.ir.uj.imm_20, id.data.ir.uj.imm_19_12, id.data.ir.uj.imm_11, id.data.ir.uj.imm_10_1, 1'b0}));

    // Register addresses
    assign id.data.rs1_addr = id.data.ir.r.rs1;
    assign id.data.rs2_addr = id.data.ir.r.rs2;
    assign id.data.reg_addr = id.data.ir.r.rd;

    // Control signals
    assign opcode = id.data.ir.r.opcode;
    assign funct3 = id.data.ir.r.funct3;
    assign funct7 = id.data.ir.r.funct7;

    // First source register mux
    always_comb
        unique case (id.ctrl.rs1_sel)
            RS_ALU:  rs1_data_mux = ex.data.alu_data;
            RS_MEM:  rs1_data_mux = mem.data.alu_data;
            RS_RAM:  rs1_data_mux = mem.data.mem_data;
            default: rs1_data_mux = id.data.rs1_data;
        endcase

    // Second source register mux
    always_comb
        unique case (id.ctrl.rs2_sel)
            RS_ALU:  rs2_data_mux = ex.data.alu_data;
            RS_MEM:  rs2_data_mux = mem.data.alu_data;
            RS_RAM:  rs2_data_mux = mem.data.mem_data;
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
        if (reset) begin
            ex.ctrl.reg_en   <= 1'b0;
            ex.ctrl.mem_op   <= LOAD_STORE_NONE;
            ex.ctrl.jmp_op   <= JMP_OP_NONE;
        end else begin
            ex.ctrl.reg_en   <= ctrl.reg_en;
            ex.ctrl.mem_op   <= ctrl.mem_op;
            ex.ctrl.alu_op   <= ctrl.alu_op;
            ex.ctrl.jmp_op   <= ctrl.jmp_op;
            ex.data.pc       <= id.data.pc;
            ex.data.op1      <= id.data.op1;
            ex.data.op2      <= id.data.op2;
            ex.data.rs1_data <= rs1_data_mux;
            ex.data.rs2_data <= rs2_data_mux;
            ex.data.reg_addr <= id.data.reg_addr;
        end
    end : decode

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

    assign ex.ctrl.branch = beq | bne | blt | bltu | bge | bgeu;
    assign ex.ctrl.jump = ex.ctrl.jmp_op == JMP_OP_JAL;

    assign target = (ex.ctrl.branch | ex.ctrl.jump) ? ex.data.alu_data : ex.data.pc + 4;

    assign ex.ctrl.load = riscv::is_load(ex.ctrl.mem_op);
    assign ex.ctrl.store = riscv::is_store(ex.ctrl.mem_op);

    alu alu (
        .opcode(ex.ctrl.alu_op),
        .op1(ex.data.op1),
        .op2(ex.data.op2),
        .out(ex.data.alu_data)
    );

    always_ff @(posedge clk) begin : execute
        if (reset) begin
            mem.ctrl.reg_en <= 1'b0;
            mem.ctrl.mem_op <= LOAD_STORE_NONE;
        end else begin
            mem.ctrl.reg_en   <= ex.ctrl.reg_en;
            mem.ctrl.mem_op   <= ex.ctrl.mem_op;
            mem.data.reg_addr <= ex.data.reg_addr;
            mem.data.alu_data <= (ex.ctrl.jump) ? ex.data.pc + 4 : ex.data.alu_data;
        end
    end : execute

///////////////////////////////////////////////////////////////////////////////

    /*
     * Memory
     */

    wire strb;

    memory #(.ADDR_WIDTH(10)) memory (
        .clk,
        .resetn,
        .op(ex.ctrl.mem_op),
        .addr(ex.data.alu_data),
        .din(ex.data.rs2_data),
        .dout(mem.data.mem_data),
        .strb,
        .idle,
        .data(data)
    );

    assign mem.ctrl.load = riscv::is_load(mem.ctrl.mem_op);
    assign mem.ctrl.store = riscv::is_store(mem.ctrl.mem_op);

    always_ff @(posedge clk) begin : writeback
        if (reset)
            wb.ctrl.reg_en <= 1'b0;
        else begin
            wb.ctrl.reg_en <= mem.ctrl.reg_en;
            wb.ctrl.load <= mem.ctrl.load;
            wb.data.reg_addr <= mem.data.reg_addr;
            wb.data.alu_data <= mem.data.alu_data;
            if (strb) wb.data.mem_data <= mem.data.mem_data;
        end
    end : writeback

///////////////////////////////////////////////////////////////////////////////

    /*
     * Writeback
     */

    assign wb.data.reg_data = (wb.ctrl.load) ? wb.data.mem_data : wb.data.alu_data;

endmodule
