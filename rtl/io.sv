/*
 * Copyright (c) 2015, C. Brett Witherspoon
 */

/**
 * Module: io
 *
 * Input/Output tristate buffers
 */
module io #(
    WIDTH = 32
)(
    input  logic [WIDTH-1:0] T,
    input  logic [WIDTH-1:0] I,
    output logic [WIDTH-1:0] O,
    inout  wire  [WIDTH-1:0] IO
);

    genvar i;
    for (i = 0; i < WIDTH; i++)
        assign IO[i] = (~T[i]) ? I[i] : 'z;

    assign O = IO;

endmodule


