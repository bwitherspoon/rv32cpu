interface rs232 #(
    parameter DATA_WIDTH = 8,
    parameter STOP_WIDTH = 1
)(
    input logic clk
);

    timeunit 1ns;
    timeprecision 1ps;

    parameter MARK  = 1'b1;
    parameter SPACE = 1'b0;

    logic txd;
    logic rxd;
    logic rts;
    logic cts;
    logic dtr;
    logic dsr;
    logic dcd;

    modport dte (
        output txd,
        input  rxd,
        output rts,
        input  cts,
        output dtr,
        input  dsr,
        input  dcd
    );

    modport dce (
        input  txd,
        output rxd,
        input  rts,
        output cts,
        input  dtr,
        output dsr,
        output dcd,
    );

endinterface
