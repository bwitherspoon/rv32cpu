/*
 * Copyright 2016 C. Brett Witherspoon
 *
 * See LICENSE for more details.
 */

/**
 * Module: writeback
 * 
 * TODO: Add module documentation
 */
module writeback
    import core::addr_t;
    import core::word_t;
    import core::wb_t;
(
    output logic  rd,
    output addr_t rd_addr,
    output word_t rd_data,
    axis.slave    slave
);
    wb_t wb;

    assign wb = slave.tdata;

    assign rd_addr = wb.data.rd.addr;

    assign rd_data = wb.data.rd.data;

    wire write = core::is_load(wb.ctrl.op) || wb.ctrl.op == core::REGISTER || wb.ctrl.op == core::JAL_OR_JALR;

    assign rd = slave.tvalid & write;

    assign slave.tready = '1; 

endmodule


