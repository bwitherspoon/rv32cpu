/*
 * Copyright 2016 C. Brett Witherspoon
 *
 * See LICENSE for more details.
 */

/**
 * Module: hazard
 *
 * TODO: Add module documentation
 */
module hazard
    import core::opcode_t;
    import core::id_t;
    import core::ex_t;
    import core::mm_t;
    import core::wb_t;
    import core::is_load;
    import core::is_store;
    import core::is_jump;
    import core::is_branch;
(
    axis.monitor decode,
    axis.monitor execute,
    axis.monitor memory,
    axis.monitor writeback,
    output logic stall,
    output logic flush
);
    id_t id;
    ex_t ex;
    mm_t mm;
    wb_t wb;

    assign id = decode.tdata;
    assign ex = execute.tdata;
    assign mm = memory.tdata;
    assign wb = writeback.tdata;

    opcode_t opcode;

    assign opcode = id.data.ir.r.opcode;

    wire id_load = opcode == core::LOAD && decode.tvalid;
    wire ex_load = is_load(ex.ctrl.op) && execute.tvalid;
    wire mm_load = is_load(mm.ctrl.op) && memory.tvalid;

    wire ex_branch = (is_jump(ex.ctrl.jmp) || is_branch(ex.ctrl.jmp)) && execute.tvalid;
    wire mm_branch = (is_jump(mm.ctrl.jmp) || is_branch(mm.ctrl.jmp)) && memory.tvalid;

    assign stall = ex_load | mm_load;
    assign flush = ex_load | mm_load | ex_branch | mm_branch;

endmodule
