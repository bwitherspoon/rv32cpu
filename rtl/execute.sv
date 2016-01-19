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
    axis.slave    up,
    axis.master   down
);
    ex_t ex;
    mm_t mm;
 
    word_t out;

    assign ex = up.tdata;

    assign down.tdata = mm;

    assign up.tready = down.tready;

    always_ff @(posedge down.aclk)
        if (~down.aresetn)
            down.tvalid <= '0;
        else
            down.tvalid <= up.tvalid;

    assign target = branch ? out : ex.data.pc + 4;

    assign bypass = out;

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

    always_ff @(posedge down.aclk) begin : registers
        if (~down.aresetn) begin
            mm.ctrl.op  <= core::NULL;
        end else begin
            mm.ctrl.op  <= ex.ctrl.op;
            mm.data.rd  <= ex.data.rd;
            mm.data.alu <= (jmp) ? ex.data.pc + 4 : out;
        end
    end : registers

endmodule

