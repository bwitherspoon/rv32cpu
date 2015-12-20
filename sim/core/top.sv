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
        repeat (2) @(posedge clk);
        #1 resetn = 1;
    endtask

    logic [3:0] led;

    core core(.*);

    initial begin
        $readmemh("main.hex", core.memory.bram.mem, 0, 5);
        $dumpfile("top.vcd");
        $dumpvars();
        reset();
        repeat (10) @(posedge clk);
        $finish;
    end

endmodule


