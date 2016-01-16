/*
 * Copyright (c) 2015, C. Brett Witherspoon
 */

`ifndef INIT_FILE
    `define INIT_FILE "boot.mem"
`endif

/**
 * Module: testbench
 */
module testbench;
    // timeunit 1ns;
    // timeprecision 1ps;

    // Clock (50 MHz)
    bit clk = 0;
    always #10ns clk <= ~clk;

    // Reset
    bit _reset;
    task reset();
        _reset = 1;
        #100ns _reset = 0;
    endtask : reset

    logic interrupt = 1'b0;

    axi code (.aclk(clk), .aresetn(~_reset));

    ram #(.INIT_DATA(core::NOP), .INIT_FILE(`INIT_FILE)) rom (.data(code));

    axi data (.aclk(clk), .aresetn(~_reset));

    ram ram (.data(data));

    axi peripheral (.aclk(clk), .aresetn(~_reset));

    cpu cpu (
        .clk,
        .reset(_reset),
        .interrupt,
        .code,
        .data,
        .peripheral
    );

    initial begin
        reset(); // GSR ~100 ns
        #900ns $finish;
    end

endmodule : testbench
