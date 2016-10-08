/*
 * Copyright (c) 2015, 2016 C. Brett Witherspoon
 */

`ifndef TEXT_FILE
    `define TEXT_FILE "testbench.text.mem"
`endif

`ifndef DATA_FILE
    `define DATA_FILE "testbench.data.mem"
`endif

/**
 * Module: testbench
 */
module testbench;
    // timeunit 1ns;
    // timeprecision 1ps;

    // Clock (100 MHz)
    bit clk = 0;
    always #5ns clk <= ~clk;

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
        $write("\nRegisters:\n\n");
        for (int i = 1; i < 32; i++) begin : dump_registers
            $write("%2d: %08h\n", i, cpu.regfile.regs[i]);
        end : dump_registers
        $write("\nMemory:\n\n");
        for (int i = 0; i < 8; i++) begin : dump_memory
            $write("%08h: ", i*4);
            for (int j = 0; j < 4; j++)
                $write("%08h ", io.blockram.mem[i+j]);
            $write("\n");
        end : dump_memory
        $write("\n");
    endtask

    initial begin
        reset(); // GSR ~100 ns

        repeat (14) @(posedge clk);
        @(negedge clk) assert(cpu.regfile.regs[7] == 5) begin
            $info("execute and memory forwarding succeeded");
        end else begin
            dump();
            $fatal(1, "execute and memory forwarding failed");
        end

        repeat (4) @(posedge clk);
        @(negedge clk) assert(cpu.regfile.regs[7] == 9) begin
            $info("memory and writeback forwarding succeeded");
        end else begin
            dump();
            $fatal(1, "memory and writeback forwarding failed");
        end

        $info("all tests succeeded");
        $finish(0);
    end

endmodule : testbench
