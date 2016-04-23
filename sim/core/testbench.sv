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

    ram #(.INIT_DATA(core::NOP), .INIT_FILE(`INIT_FILE)) rom (.bus(code));
    ram ram (.bus(data));
    ram io (.bus(mmio));

    cpu cpu (.*);

    task dump();
        $error("dumping memory contents");
        for (int i = 0; i < 8; i++) begin : pretty_print
            $write("%08d:", i*4);
            for (int j = 0; j < 4; j++)
                $write("%08h ", io.blockram.mem[i+j]);
            $write("\n");
        end : pretty_print
    endtask

    initial begin
        reset(); // GSR ~100 ns
        repeat (100) @(posedge clk);
        $finish;
    end

endmodule : testbench
