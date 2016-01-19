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
    import core::ctrl_t;
    import core::ex_t;
    import core::mm_t;
    import core::wb_t;
    import core::is_load;
    import core::is_store;
    import core::is_jump;
    import core::is_branch;
(
    input ctrl_t control,
    axis.monitor decode,
    axis.monitor execute,
    axis.monitor memory,
    axis.monitor writeback,
    output logic bubble
);
    ex_t   ex;
    mm_t   mm;
    wb_t   wb;

    assign ex = execute.tdata;
    assign mm = memory.tdata;
    assign wb = writeback.tdata;

    wire load_store =  (is_load(control.op) || is_store(control.op)) && decode.tvalid ||
                       (is_load(ex.ctrl.op) || is_store(ex.ctrl.op)) && execute.tvalid ||
                       (is_load(mm.ctrl.op) || is_store(mm.ctrl.op)) && memory.tvalid;

    wire jump_branch = (is_jump(control.jmp) || is_branch(control.jmp)) && decode.tvalid ||
                       (is_jump(ex.ctrl.jmp) || is_branch(ex.ctrl.jmp)) && execute.tvalid;

    assign bubble = load_store | jump_branch;

endmodule
