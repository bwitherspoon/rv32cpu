/**
 * Module: core
 *
 * The processor core.
 */
module core (
    input logic clk,
    input logic resetn
);

    regfile regfile (
        .clk(clk)
    );

    fetch fetch (
        .clk(clk)
    );

    execute execute (
        .clk(clk)
    );

endmodule
