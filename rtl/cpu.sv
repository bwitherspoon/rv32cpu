/*
 * Copyright (c) 2015, 2016 C. Brett Witherspoon
 */

/**
 * Module: cpu
 */
module cpu
    import core::addr_t;
    import core::ctrl_t;
    import core::fun_t;
    import core::imm_t;
    import core::inst_t;
    import core::jmp_t;
    import core::op_t;
    import core::rs_t;
    import core::word_t;
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
            rs_t rs1;
            rs_t rs2;
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
            fun_t    fun;
            op_t     op;
            jmp_t    jmp;
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
            fun_t fun;
            logic load;
            logic store;
        } ctrl;
        struct packed {
            addr_t reg_addr;
            word_t alu_data;
            word_t mem_data;
        } data;
    } mem;

    struct packed {
        struct packed {
            logic register;
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
    wire jump = ctrl.jmp == core::JAL_OR_JALR;

    // Bubble after load to account for load latency
    wire load = core::is_load(ctrl.fun);

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
            && ex.ctrl.fun == core::REGISTER)
            id.ctrl.rs1 = core::ALU;
        else if (id.data.rs1_addr == mem.data.reg_addr
                 && id.data.rs1_addr != '0
                 && mem.ctrl.fun == core::REGISTER)
            id.ctrl.rs1 = core::MEM;
        else if (id.data.rs1_addr == mem.data.reg_addr
                 && id.data.rs1_addr != '0
                 && mem.ctrl.load == '1)
            id.ctrl.rs1 = core::RAM;
        else
            id.ctrl.rs1 = core::REG;

    always_comb
        if (id.data.rs2_addr == ex.data.reg_addr
            && id.data.rs2_addr != '0
            && ex.ctrl.fun == core::REGISTER)
            id.ctrl.rs2 = core::ALU;
        else if (id.data.rs2_addr == mem.data.reg_addr
                 && id.data.rs2_addr != '0
                 && mem.ctrl.fun == core::REGISTER)
            id.ctrl.rs2 = core::MEM;
        else if (id.data.rs2_addr == mem.data.reg_addr
                 && id.data.rs2_addr != '0
                 && mem.ctrl.load == '1)
            id.ctrl.rs2 = core::RAM;
        else
            id.ctrl.rs2 = core::REG;

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
        .handler(core::TRAP_BASE),
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

    ctrl_t   ctrl;

    word_t rs1_data;
    word_t rs2_data;

    imm_t i_imm;
    imm_t s_imm;
    imm_t b_imm;
    imm_t u_imm;
    imm_t j_imm;

    // Control decoder
    control control (
        .opcode(id.data.ir.r.opcode),
        .funct3(id.data.ir.r.funct3),
        .funct7(id.data.ir.r.funct7),
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
        .rd_en(wb.ctrl.register),
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

    // First source register mux
    always_comb
        unique case (id.ctrl.rs1)
            core::ALU: rs1_data = ex.data.alu_data;
            core::MEM: rs1_data = mem.data.alu_data;
            core::RAM: rs1_data = mem.data.mem_data;
            default:   rs1_data = id.data.rs1_data;
        endcase

    // Second source register mux
    always_comb
        unique case (id.ctrl.rs2)
            core::ALU: rs2_data = ex.data.alu_data;
            core::MEM: rs2_data = mem.data.alu_data;
            core::RAM: rs2_data = mem.data.mem_data;
            default:   rs2_data = id.data.rs2_data;
        endcase

    // First operand mux
    always_comb
        unique case (ctrl.op1)
            core::PC: id.data.op1 = id.data.pc;
            default:  id.data.op1 = rs1_data;
        endcase

    // Second operand mux
    always_comb
        unique case (ctrl.op2)
            core::I_IMM: id.data.op2 = i_imm;
            core::S_IMM: id.data.op2 = s_imm;
            core::B_IMM: id.data.op2 = b_imm;
            core::U_IMM: id.data.op2 = u_imm;
            core::J_IMM: id.data.op2 = j_imm;
            default:     id.data.op2 = rs2_data;
        endcase

    always_ff @(posedge clk) begin : decode
        if (reset) begin
            ex.ctrl.fun <= core::NULL;
            ex.ctrl.jmp <= core::NONE;
        end else begin
            ex.ctrl.fun      <= ctrl.fun;
            ex.ctrl.op       <= ctrl.op;
            ex.ctrl.jmp      <= ctrl.jmp;
            ex.data.pc       <= id.data.pc;
            ex.data.op1      <= id.data.op1;
            ex.data.op2      <= id.data.op2;
            ex.data.rs1_data <= rs1_data;
            ex.data.rs2_data <= rs2_data;
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

    wire beq  = ex.ctrl.jmp == core::BEQ  & eq;
    wire bne  = ex.ctrl.jmp == core::BNE  & ~eq;
    wire blt  = ex.ctrl.jmp == core::BLT  & lt;
    wire bltu = ex.ctrl.jmp == core::BLTU & ltu;
    wire bge  = ex.ctrl.jmp == core::BGE  & (eq | ~lt);
    wire bgeu = ex.ctrl.jmp == core::BGEU & (eq | ~ltu);

    assign ex.ctrl.branch = beq | bne | blt | bltu | bge | bgeu;
    assign ex.ctrl.jump = ex.ctrl.jmp == core::JAL_OR_JALR;

    assign target = (ex.ctrl.branch | ex.ctrl.jump) ? ex.data.alu_data : ex.data.pc + 4;

    assign ex.ctrl.load = core::is_load(ex.ctrl.fun);
    assign ex.ctrl.store = core::is_store(ex.ctrl.fun);

    alu alu (
        .opcode(ex.ctrl.op),
        .op1(ex.data.op1),
        .op2(ex.data.op2),
        .out(ex.data.alu_data)
    );

    always_ff @(posedge clk) begin : execute
        if (reset) begin
            mem.ctrl.fun <= core::NULL;
        end else begin
            mem.ctrl.fun      <= ex.ctrl.fun;
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
        .fun(ex.ctrl.fun),
        .addr(ex.data.alu_data),
        .din(ex.data.rs2_data),
        .dout(wb.data.mem_data),
        .bypass(mem.data.mem_data),
        .idle,
        .data(data)
    );

    assign mem.ctrl.load = core::is_load(mem.ctrl.fun);
    assign mem.ctrl.store = core::is_store(mem.ctrl.fun);

    always_ff @(posedge clk) begin : writeback
        if (reset)
            wb.ctrl.register <= 1'b0;
        else begin
            wb.ctrl.register <= mem.ctrl.fun == core::REGISTER;
            wb.ctrl.load     <= mem.ctrl.load;
            wb.data.reg_addr <= mem.data.reg_addr;
            wb.data.alu_data <= mem.data.alu_data;
        end
    end : writeback

///////////////////////////////////////////////////////////////////////////////

    /*
     * Writeback
     */

    assign wb.data.reg_data = (wb.ctrl.load) ? wb.data.mem_data : wb.data.alu_data;

endmodule
