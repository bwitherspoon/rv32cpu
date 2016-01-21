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

    assign target = branch ? out : ex.data.pc + 4;

    assign bypass = out;

    // Comparators
    wire eq  = ex.data.rs1 == ex.data.rs2;
    wire lt  = signed'(ex.data.rs1) < signed'(ex.data.rs2);
    wire ltu = ex.data.rs1 < ex.data.rs2;

    // Jump / Branch
    wire jmp  = ex.ctrl.br == core::JAL_JALR;
    wire beq  = ex.ctrl.br == core::BEQ  & eq;
    wire bne  = ex.ctrl.br == core::BNE  & ~eq;
    wire blt  = ex.ctrl.br == core::BLT  & lt;
    wire bltu = ex.ctrl.br == core::BLTU & ltu;
    wire bge  = ex.ctrl.br == core::BGE  & (eq | ~lt);
    wire bgeu = ex.ctrl.br == core::BGEU & (eq | ~ltu);

    assign branch = jmp | beq | bne | blt | bltu | bge | bgeu;

    alu alu (
        .fun(ex.ctrl.fun),
        .op1(ex.data.op1),
        .op2(ex.data.op2),
        .out
    );

    always_ff @(posedge down.aclk)
        if (~down.aresetn)
            down.tvalid <= '0;
        else if (down.tready)
            down.tvalid <= up.tvalid;
        else if (down.tvalid)
            down.tvalid <= '0;

    always_ff @(posedge down.aclk) begin : registers
        if (~down.aresetn) begin
            mm.ctrl.op  <= core::NULL;
            mm.ctrl.br <= core::NONE;
            mm.data.rd <= '0;
        end else if (down.tready) begin
            mm.ctrl.op  <= ex.ctrl.op;
            mm.ctrl.br <= ex.ctrl.br;
            mm.data.rd  <= ex.data.rd;
            mm.data.alu <= (jmp) ? ex.data.pc + 4 : out;
            mm.data.rs2 <= ex.data.rs2;
        end
    end : registers

endmodule

