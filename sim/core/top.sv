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
        $readmemh("main.txt", core.memory.ram.mem);
        $dumpfile("top.vcd");
        $dumpvars();

        $monitor("%g: M[512]=%H", $time, core.memory.ram.mem[128]);

        reset();
        repeat (25) @(posedge clk);
        $finish;
    end

endmodule


