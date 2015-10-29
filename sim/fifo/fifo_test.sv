module fifo_test;

    timeunit 1ns;
    timeprecision 1ps;

    localparam CLOCK_PERIOD = 100;
    localparam DATA_WIDTH   = 8;
    localparam DATA_DEPTH   = 32;
    localparam ADDR_WIDTH   = $clog2(DATA_DEPTH);

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

    axis #(.DATA_WIDTH(DATA_WIDTH)) read (.aclk(clk), .aresetn(resetn));
    axis #(.DATA_WIDTH(DATA_WIDTH)) write (.aclk(clk), .aresetn(resetn));
    fifo #(.DATA_WIDTH(DATA_WIDTH),.ADDR_WIDTH(ADDR_WIDTH)) dut (.*);

    // Subroutines
    typedef enum bit {failure, success} status;

    task automatic read_and_write;

        bit [DATA_WIDTH-1:0] response [0:DATA_DEPTH-1];
        bit [DATA_WIDTH-1:0] stimulus [0:DATA_DEPTH-1];

        status status = success;

        foreach (stimulus[i]) stimulus[i] = $random($time) % (2**DATA_WIDTH);

        reset();

        fork
            foreach (stimulus[i]) write_master(stimulus[i]);
            foreach (response[i]) read_slave(response[i]);
        join

        assert(stimulus === response) else status = failure;

        $display("\t| read_and_write | %s |", status.name);

    endtask

    task automatic full_and_empty;

        bit [DATA_WIDTH-1:0] response [0:DATA_DEPTH-1];
        bit [DATA_WIDTH-1:0] stimulus [0:DATA_DEPTH-1];

        status status = success;

        foreach (stimulus[i]) stimulus[i] = $random($time) % (2**DATA_WIDTH);

        reset();

        foreach (stimulus[i]) write_master(stimulus[i]);

        assert(dut.full === 1'b1) else begin
            $error("Assertion violation: full signal not asserted");
            status = failure;
        end

        foreach (response[i]) read_slave(response[i]);

        assert(dut.empty === 1'b1) else begin
            $error("Assertion violation: empty signal not asserted");
            status = failure;
        end

        assert(stimulus === response) else begin
            $error("Assertion violation: stimulus not equal to response");
            status = failure;
        end

        $display("\t| full_and_empty | %s |", status.name);

    endtask

    task read_slave (output logic [DATA_WIDTH-1:0] item);
        read.tready = 1;
        wait (read.tvalid) @(posedge clk);
        #1 item = read.tdata;
        read.tready = 0;
    endtask

    task write_master (input logic [DATA_WIDTH-1:0] item);
        write.tdata = item;
        write.tvalid = 1;
        wait (write.tready) @(posedge clk);
        #1 write.tvalid = 0;
    endtask

    // Testbench
    initial begin
        // GSR
        #100ns

        // Scoreboard
        $display("\t+--------------------------+");
        $display("\t| Test           | Status  |");
        $display("\t+----------------+---------+");
        full_and_empty();
        $display("\t+----------------+---------+");
        read_and_write();
        $display("\t+----------------+---------+");

        @(posedge clk) $finish;
    end

endmodule

