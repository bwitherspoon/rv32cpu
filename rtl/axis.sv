/*
 * Copyright 2016 C. Brett Witherspoon
 *
 * See LICENSE for more details.
 */

interface axis #(
    parameter DATA_WIDTH = 32,
    parameter ID_WIDTH   = 4,
    parameter DEST_WIDTH = 4,
    parameter USER_WIDTH = 16
)(
    input aclk,
    input aresetn
);
    localparam STRB_WIDTH = DATA_WIDTH / 8;
    localparam KEEP_WIDTH = STRB_WIDTH;

    typedef logic [DATA_WIDTH-1:0] data_t;
    typedef logic [STRB_WIDTH-1:0] strb_t;
    typedef logic [KEEP_WIDTH-1:0] keep_t;
    typedef logic [ID_WIDTH-1:0]   id_t;
    typedef logic [DEST_WIDTH-1:0] dest_t;
    typedef logic [USER_WIDTH-1:0] user_t;

    data_t  tdata;
    strb_t  tstrb;
    keep_t  tkeep;
    id_t    tid;
    dest_t  tdest;
    user_t  tuser;
    logic   tlast;
    logic   tvalid;
    logic   tready;

    modport master (
        input  aclk,
        input  aresetn,
        output tdata,
        output tstrb,
        output tkeep,
        output tid,
        output tdest,
        output tuser,
        output tlast,
        output tvalid,
        input  tready
    );

    modport slave (
        input  aclk,
        input  aresetn,
        input  tdata,
        input  tstrb,
        input  tkeep,
        input  tid,
        input  tdest,
        input  tuser,
        input  tlast,
        input  tvalid,
        output tready
    );

    modport monitor (
        input aclk,
        input aresetn,
        input tdata,
        input tstrb,
        input tkeep,
        input tid,
        input tdest,
        input tuser,
        input tlast,
        input tvalid,
        input tready
    );

endinterface : axis
