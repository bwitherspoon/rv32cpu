module top;
    // timeunit 1ns;
    // timeprecision 1ps;

    import riscv::*;

    localparam PERIOD = 10;

    // Clock
    bit clk = 0;
    initial forever #(PERIOD/2) clk = ~clk;

    // Reset
    bit resetn = 1;
    task reset();
        resetn = 0;
        @(posedge clk);
        #(PERIOD/2) resetn = 1;
    endtask

    logic [15:0] gpio;

    core core(.*);

    initial begin
        reset(); // GSR ~100 ns
        repeat (10) @(posedge clk);
        $finish;
    end

endmodule


