/**
 * Module: core
 *
 * The processor core.
 */
module core (
    input logic clk,
    input logic resetn
);

    control control (
        .clk(clk)
    );

    regfile regfile (
        .clk(clk)
    );

    fetch fetch (
        .clk(clk)
    );

    decode decode (
        .clk(clk)
    );

    execute execute (
        .clk(clk)
    );

    memory memory (
        .clk(clk)
    );

endmodule
