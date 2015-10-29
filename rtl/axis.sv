interface axis #(
    parameter DATA_WIDTH = 32
)(
    input logic aclk,
    input logic aresetn
);

    typedef logic [DATA_WIDTH-1:0] data_t;

    data_t tdata;
    logic  tvalid;
    logic  tready;

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
