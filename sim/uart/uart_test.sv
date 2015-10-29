module uart_test;

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

    rs232 serial(.*);
    
    axis read(
        .aclk(clk),
        .aresetn(resetn));
    
    axis write(
        .aclk(clk),
        .aresetn(resetn));
    
    uart dut(
        .clk(clk),
        .resetn(resetn),
        .dce(serial.dce),
        .slave(read.slave),
        .master(write.master));

    // Testbench
    initial begin
        // GSR
        #100ns

        // Scoreboard
        $display("\t+--------------------------+");
        $display("\t| Test           | Status  |");
        $display("\t+----------------+---------+");
        $display("\t+                +         +");
        $display("\t+----------------+---------+");

        @(posedge clk) $finish;
    end

endmodule
