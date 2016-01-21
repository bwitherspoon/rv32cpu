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
    import core::isload;
    import core::isstore;
    import core::isjump;
    import core::isbranch;
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
    wire ex_load = isload(ex.ctrl.op) && execute.tvalid;
    wire mm_load = isload(mm.ctrl.op) && memory.tvalid;

    wire ex_branch = (isjump(ex.ctrl.br) || isbranch(ex.ctrl.br)) && execute.tvalid;
    wire mm_branch = (isjump(mm.ctrl.br) || isbranch(mm.ctrl.br)) && memory.tvalid;

    assign stall = ex_load | mm_load;
    assign flush = ex_load | mm_load | ex_branch | mm_branch;

endmodule
