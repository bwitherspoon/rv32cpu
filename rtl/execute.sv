/*
 * Copyright 2016-2018 C. Brett Witherspoon
 *
 * See LICENSE for more details.
 */

/**
 * Module: execute
 *
 * Execute stage
 */
module execute
    import rv32::ex_t;
    import rv32::mm_t;
    import rv32::word_t;
(
    output logic  branch,
    output word_t target,
    output word_t bypass,
    axis.slave    source,
    axis.master   sink
);
    ex_t ex;
    mm_t mm;

    word_t out;

    assign ex = source.tdata;

    assign sink.tdata = mm;

    assign target = branch ? out : ex.data.pc + 4;

    assign bypass = out;

    // Comparators
    wire eq  = ex.data.rs1 == ex.data.rs2;
    wire lt  = signed'(ex.data.rs1) < signed'(ex.data.rs2);
    wire ltu = ex.data.rs1 < ex.data.rs2;

    // Jump / Branch
    wire jmp  = ex.ctrl.op == rv32::JUMP;
    wire beq  = ex.ctrl.op == rv32::BRANCH & ex.ctrl.br == rv32::BEQ  & eq;
    wire bne  = ex.ctrl.op == rv32::BRANCH & ex.ctrl.br == rv32::BNE  & ~eq;
    wire blt  = ex.ctrl.op == rv32::BRANCH & ex.ctrl.br == rv32::BLT  & lt;
    wire bltu = ex.ctrl.op == rv32::BRANCH & ex.ctrl.br == rv32::BLTU & ltu;
    wire bge  = ex.ctrl.op == rv32::BRANCH & ex.ctrl.br == rv32::BGE  & (eq | ~lt);
    wire bgeu = ex.ctrl.op == rv32::BRANCH & ex.ctrl.br == rv32::BGEU & (eq | ~ltu);

    assign branch = source.tvalid & (jmp | beq | bne | blt | bltu | bge | bgeu);

    alu alu (
        .fn(ex.ctrl.fn),
        .op1(ex.data.op1),
        .op2(ex.data.op2),
        .out
    );

    assign source.tready = sink.tready;

    always_ff @(posedge sink.aclk)
        if (~sink.aresetn)
            sink.tvalid <= '0;
        else if (source.tvalid & source.tready)
            sink.tvalid <= '1;
        else if (sink.tvalid & sink.tready)
            sink.tvalid <= '0;

    always_ff @(posedge sink.aclk) begin : registers
        if (sink.tready) begin
            mm.ctrl.op  <= ex.ctrl.op;
            mm.ctrl.br <= ex.ctrl.br;
            mm.data.rd  <= ex.data.rd;
            mm.data.alu <= (jmp) ? ex.data.pc + 4 : out;
            mm.data.rs2 <= ex.data.rs2;
        end
    end : registers

endmodule
