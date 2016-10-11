/*
 * Copyright 2016 C. Brett Witherspoon
 *
 * See LICENSE for more details.
 */

/**
 * Module: forward
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

    wire ex_rs1 = execute.tvalid && id.data.ir.r.rs1 == ex.data.rd && isinteger(ex.ctrl.op);
    wire mm_rs1 = memory.tvalid && id.data.ir.r.rs1 == mm.data.rd && isinteger(mm.ctrl.op);
    wire wb_rs1 = writeback.tvalid && id.data.ir.r.rs1 == wb.data.rd.addr && (isinteger(wb.ctrl.op) || isload(wb.ctrl.op));

    wire ex_rs2 = execute.tvalid && id.data.ir.r.rs2 == ex.data.rd && isinteger(ex.ctrl.op);
    wire mm_rs2 = memory.tvalid && id.data.ir.r.rs2 == mm.data.rd && isinteger(mm.ctrl.op);
    wire wb_rs2 = writeback.tvalid && id.data.ir.r.rs2 == wb.data.rd.addr && (isinteger(wb.ctrl.op) || isload(wb.ctrl.op));

    always_comb begin : src1
        rs1 = core::REG;
        if (id.data.ir.r.rs1 != 0) begin
            if (ex_rs1)
                rs1 = core::ALU;
            else if (mm_rs1)
                rs1 = core::EXE;
            else if (wb_rs1)
                rs1 = core::MEM;
        end
    end : src1

    always_comb begin : src2
        rs2 = core::REG;
        if (id.data.ir.r.rs2 != 0) begin
            if (ex_rs2)
                rs2 = core::ALU;
            else if (mm_rs2)
                rs2 = core::EXE;
            else if (wb_rs2)
                rs2 = core::MEM;
        end
    end : src2

endmodule : forward

