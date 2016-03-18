/*
 * Copyright 2016 C. Brett Witherspoon
 *
 * See LICENSE for more details.
 */

/**
 * Module: execute
<<<<<<< HEAD
=======
 *
 * Execute stage
>>>>>>> master
 */
module execute
    import core::ex_t;
    import core::mm_t;
    import core::word_t;
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

    assign source.tready = sink.tready;

    assign target = branch ? out : ex.data.pc + 4;

    assign bypass = out;

    // Comparators
    wire eq  = ex.data.rs1 == ex.data.rs2;
    wire lt  = signed'(ex.data.rs1) < signed'(ex.data.rs2);
    wire ltu = ex.data.rs1 < ex.data.rs2;

    // Jump / Branch
    wire jmp  = ex.ctrl.op == core::JUMP;
    wire beq  = ex.ctrl.op == core::BRANCH & ex.ctrl.br == core::BEQ  & eq;
    wire bne  = ex.ctrl.op == core::BRANCH & ex.ctrl.br == core::BNE  & ~eq;
    wire blt  = ex.ctrl.op == core::BRANCH & ex.ctrl.br == core::BLT  & lt;
    wire bltu = ex.ctrl.op == core::BRANCH & ex.ctrl.br == core::BLTU & ltu;
    wire bge  = ex.ctrl.op == core::BRANCH & ex.ctrl.br == core::BGE  & (eq | ~lt);
    wire bgeu = ex.ctrl.op == core::BRANCH & ex.ctrl.br == core::BGEU & (eq | ~ltu);

    assign branch = jmp | beq | bne | blt | bltu | bge | bgeu;

    alu alu (
        .fun(ex.ctrl.fun),
        .op1(ex.data.op1),
        .op2(ex.data.op2),
        .out
    );

    always_ff @(posedge sink.aclk)
        if (~sink.aresetn)
            sink.tvalid <= '0;
        else if (source.tvalid)
            sink.tvalid <= '1;
        else if (sink.tvalid & sink.tready)
            sink.tvalid <= '0;

    always_ff @(posedge sink.aclk) begin : registers
        if (~sink.aresetn) begin
            mm.ctrl.op  <= core::NONE;
            mm.ctrl.br <= core::IGNORE;
            mm.data.rd <= '0;
        end else if (sink.tready) begin
            mm.ctrl.op  <= ex.ctrl.op;
            mm.ctrl.br <= ex.ctrl.br;
            mm.data.rd  <= ex.data.rd;
            mm.data.alu <= (jmp) ? ex.data.pc + 4 : out;
            mm.data.rs2 <= ex.data.rs2;
        end
    end : registers

endmodule

