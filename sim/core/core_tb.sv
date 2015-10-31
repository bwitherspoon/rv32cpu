module core_test;

    timeunit 1ns;
    timeprecision 1ps;

    localparam CLOCK_PERIOD = 100;

      // Clock
    bit clk = 0;
    initial forever #(CLOCK_PERIOD/2) clk = ~clk;

    // Reset
    bit resetn = 1;
    task reset();
        @(posedge clk) #1 resetn = 0;
        @(posedge clk) #1 resetn = 1;
        @(posedge clk) #1;
    endtask

    core core(.*);

    initial $finish;

endmodule


