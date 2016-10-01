/*
 * Copyright (c) 2015, 2016 C. Brett Witherspoon
 */

`ifndef TEXT_FILE
    `define TEXT_FILE "calc.text.mem"
`endif

`ifndef DATA_FILE
    `define DATA_FILE "calc.data.mem"
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

    ram #(.INIT_DATA(core::NOP), .INIT_FILE(`TEXT_FILE)) rom (.bus(code));
    ram #(.INIT_FILE(`DATA_FILE)) ram (.bus(data));
    ram #(.DATA_DEPTH(2048)) io (.bus(mmio));

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
