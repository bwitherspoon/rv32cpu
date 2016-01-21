/*
 * Copyright 2016 C. Brett Witherspoon
 *
 * See LICENSE for more details.
 */

/**
 * Module: forward
 * 
 * TODO: Add module documentation
 */
module forward
    import core::id_t;
    import core::ex_t;
    import core::mm_t;
    import core::wb_t;
    import core::rs_t;
    import core::isinteger;
    import core::isload;
(
    axis.monitor decode,
    axis.monitor execute,
    axis.monitor memory,
    axis.monitor writeback,
    output rs_t  rs1,
    output rs_t  rs2
);
    id_t id;
    ex_t ex;
    mm_t mm;
    wb_t wb;

    assign id = decode.tdata;
    assign ex = execute.tdata;
    assign mm = memory.tdata;
    assign wb = writeback.tdata;

    wire ex_reg_store = isinteger(ex.ctrl.op) | isload(ex.ctrl.op);
    wire mm_reg_store = isinteger(mm.ctrl.op) | isload(mm.ctrl.op);

    wire id_ex_rs1_rd = id.data.ir.r.rs1 == ex.data.rd;
    wire id_mm_rs1_rd = id.data.ir.r.rs1 == mm.data.rd;

    wire id_ex_rs2_rd = id.data.ir.r.rs2 == ex.data.rd;
    wire id_mm_rs2_rd = id.data.ir.r.rs2 == mm.data.rd;

    always_comb begin : src1
        rs1 = core::REG;
        if (id.data.ir.r.rs1 != 0)
            if (id_ex_rs1_rd & ex_reg_store)
                rs1 = core::ALU;
            else if (id_mm_rs1_rd & mm_reg_store)
                rs1 = core::EXE;
    end : src1

    always_comb begin : src2
        rs2 = core::REG;
        if (id.data.ir.r.rs2 != 0)
            if (id_ex_rs2_rd & ex_reg_store)
                rs2 = core::ALU;
            else if (id_mm_rs2_rd & mm_reg_store)
                rs2 = core::EXE;
    end : src2

endmodule : forward


