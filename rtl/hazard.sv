/*
 * Copyright 2016 C. Brett Witherspoon
 *
 * See LICENSE for more details.
 */

/**
 * Module: hazard
 */
module hazard
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
    output logic bubble,
    output logic stall
);
    id_t id;
    ex_t ex;
    mm_t mm;
    wb_t wb;

    opcodes::opcode_t opcode;

    assign id = decode.tdata;
    assign ex = execute.tdata;
    assign mm = memory.tdata;
    assign wb = writeback.tdata;

    assign opcode = id.data.ir.r.opcode;

    wire jump = opcode === opcodes::JAL ||
                opcode === opcodes::JALR ||
                opcode === opcodes::BRANCH;

    assign bubble = decode.tvalid & jump;

    assign stall = (execute.tvalid & core::isload(ex.ctrl.op)) | (memory.tvalid & core::isload(mm.ctrl.op));

endmodule
