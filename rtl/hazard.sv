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
    import opcodes::opcode_t;
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
    output logic bubble
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

    wire branch = opcode == opcodes::JAL || opcode == opcodes::JALR ||
                  opcode == opcodes::BRANCH;

    assign bubble = branch;

endmodule
