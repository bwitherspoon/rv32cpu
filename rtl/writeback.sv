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
    axis.slave    up
);
    wb_t wb;

    assign wb = up.tdata;

    assign rd = wb.ctrl.op == core::REGISTER;

    assign rd_addr = wb.data.rd.addr;

    assign rd_data = wb.data.rd.data;

    assign up.tready = '1;

endmodule


