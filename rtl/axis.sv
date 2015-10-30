interface axis #(
    parameter TDATA_WIDTH = 8,
)(
    input logic aclk,
    input logic aresetn
);
    timeunit 1ns;
    timeprecision 1ps;

    typedef logic [TDATA_WIDTH-1:0] tdata_t;

    tdata_t tdata;
    logic   tvalid;
    logic   tready;

    modport master (
        output tvalid,
        output tdata,
        input  tready
    );

    modport slave (
        input  tvalid,
        input  tdata,
        output tready
    );

endinterface : axis
