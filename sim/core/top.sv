module top;
    timeunit 1ns;
    timeprecision 1ps;

    import riscv::*;

    localparam PERIOD = 100;

    // Clock
    bit clk = 0;
    initial forever #(PERIOD/2) clk = ~clk;

    // Reset
    bit resetn = 1;
    task reset();
        resetn = 0;
        @(posedge clk) #1 resetn = 1;
    endtask

    core core(.*);

    initial begin
        $readmemh("main.txt", core.memory.bram.mem, 0, 31);
        //$monitor("x1: %h", core.regfile.regs[1]);
        //$monitor("x2: %h", core.regfile.regs[2]);
        $dumpvars();
        reset();
        repeat (32) @(posedge clk);
        $finish;
    end

endmodule


