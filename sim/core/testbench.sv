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
    bit rst;
    task reset();
        rst = 1;
        #100ns rst = 0;
    endtask : reset

    wire aclk = clk;
    wire aresetn = ~rst;

    logic irq = 1'b0;

    axi code (.*);
    axi data (.*);
    axi mmio (.*);

    ram #(.INIT_DATA(core::NOP), .INIT_FILE(`INIT_FILE)) rom (.data(code));
    ram ram (.data(data));
    ram io (.data(mmio));

    cpu cpu (.*);

    initial begin
        reset(); // GSR ~100 ns
        #900ns $finish;
    end

endmodule : testbench
