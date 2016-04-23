/*
 * Copyright 2016 C. Brett Witherspoon
 *
 * See LICENSE for more details.
 */

/**
 * Module: writeback
 */
module writeback
    import core::addr_t;
    import core::word_t;
    import core::wb_t;
    import core::isinteger;
    import core::isload;
    import core::isjump;
(
    output logic  rd_load,
    output addr_t rd_addr,
    output word_t rd_data,
    output word_t count,
    axis.slave    source
);
    wb_t wb;

    assign wb = source.tdata;

    assign rd_load = isinteger(wb.ctrl.op) | isload(wb.ctrl.op) | isjump(wb.ctrl.op);

    assign rd_addr = wb.data.rd.addr;

    assign rd_data = wb.data.rd.data;

    assign source.tready = '1;

    always_ff @(posedge source.aclk)
        if (~source.aresetn)
            count <= '0;
        else if (source.tvalid & source.tready)
            count <= count + 1;

endmodule


