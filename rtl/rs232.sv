interface rs232 #(
    parameter DATA_BITS = 8,
    parameter STOP_BITS = 1  
)(
    input logic clk
);
    localparam MARK  = 1'b1;
    localparam SPACE = 1'b0;

    logic txd;
    logic rxd;
    logic rts;
    logic cts;
    logic dtr;
    logic dsr;
    logic dcd;

    modport dte (
        output txd,
        input  rxd,
        output rts,
        input  cts,
        output dtr,
        input  dsr,
        input  dcd
    );

    modport dce (
        input  txd,
        output rxd,
        input  rts,
        output cts,
        input  dtr,
        output dsr,
        output dcd
    );
    
    task automatic transmit(input logic [DATA_BITS-1:0] data);
        // Start
        txd = SPACE;
        repeat (16) @(posedge clk);
        // Data
        for (int i = 0; i < DATA_BITS; i++) begin
            txd = data[i];
            repeat (16) @(posedge clk);
        end
        // Stop
        repeat (STOP_BITS) begin
            txd = MARK;
            repeat (16) @(posedge clk);
        end
    endtask

    task automatic receive(output logic [DATA_BITS-1:0] data);
        // Start
        wait (rxd === SPACE);
        repeat (8) @(posedge clk);
        assert (rxd === SPACE);
        // Data
        for (int i = 0; i < DATA_BITS; i++) begin
            repeat (8) @(posedge clk);
            data[i] = rxd;
        end
        // Stop
        repeat (STOP_BITS) begin
            repeat (8) @(posedge clk);
            assert (rxd === MARK);
        end
    endtask

endinterface
