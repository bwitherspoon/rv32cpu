/*
 * Copyright 2016-2018 C. Brett Witherspoon
 *
 * See LICENSE for more details.
 */

/**
 * Module: hazard
 */
module hazard
    import rv32::id_t;
    import rv32::ex_t;
    import rv32::mm_t;
    import rv32::wb_t;
    import rv32::isload;
    import rv32::isstore;
    import rv32::isjump;
    import rv32::isbranch;
(
    axis.monitor decode,
    axis.monitor execute,
    axis.monitor memory,
    axis.monitor writeback,
    output logic stall,
    output logic lock
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

    assign stall = decode.tvalid & jump;

    assign lock = (execute.tvalid & rv32::isload(ex.ctrl.op)) | (memory.tvalid & rv32::isload(mm.ctrl.op));

endmodule
