/*
 * Copyright 2016 C. Brett Witherspoon
 *
 * See LICENSE for more details.
 */

/**
 * Module: execute
 *
 * TODO: Add module documentation
 */
module execute
    import core::ex_t;
    import core::mm_t;
    import core::word_t;
(
    output logic  branch,
    output word_t target,
    output word_t bypass,
    axis.slave    down,
    axis.master   up
);
    ex_t ex;
    mm_t mm;
    word_t out;

    assign ex = down.tdata;

    assign up.tdata = mm;

    assign down.tready = up.tready;

    assign target = out;

    // Comparators
    wire eq  = ex.data.rs1 == ex.data.rs2;
    wire lt  = signed'(ex.data.rs1) < signed'(ex.data.rs2);
    wire ltu = ex.data.rs1 < ex.data.rs2;

    // Jump / Branch
    wire jmp  = ex.ctrl.jmp == core::JAL_OR_JALR;
    wire beq  = ex.ctrl.jmp == core::BEQ  & eq;
    wire bne  = ex.ctrl.jmp == core::BNE  & ~eq;
    wire blt  = ex.ctrl.jmp == core::BLT  & lt;
    wire bltu = ex.ctrl.jmp == core::BLTU & ltu;
    wire bge  = ex.ctrl.jmp == core::BGE  & (eq | ~lt);
    wire bgeu = ex.ctrl.jmp == core::BGEU & (eq | ~ltu);

    assign branch = jmp | beq | bne | blt | bltu | bge | bgeu;

    alu alu (
        .fun(ex.ctrl.fun),
        .op1(ex.data.op1),
        .op2(ex.data.op2),
        .out
    );

    always_ff @(posedge up.aclk) begin : registers
        if (~up.aresetn) begin
            mm.ctrl.op  <= core::NULL;
        end else begin
            mm.ctrl.op  <= ex.ctrl.op;
            mm.data.rd  <= ex.data.rd;
            mm.data.alu <= (jmp) ? ex.data.pc + 4 : out;
        end
    end : registers

endmodule

