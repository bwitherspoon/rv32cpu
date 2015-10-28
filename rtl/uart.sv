/**
 * Module: uart
 * 
 * A UART controller.
 */
module uart #(
    parameter DATA_BITS = 8,
    parameter STOP_BITS = 1
)(
    input logic clk,
    input logic resetn,
    rs232.dce   serial,
    axis.slave  read,
    axis.master write
);

    timeunit 1ns;
    timeprecision 1ps;

    enum {IDLE, START, DATA, STOP} state = IDLE;
    logic [2:0] timer = '0;
    logic [2:0] count = '0;
    logic [7:0] data  = '0;

    // Receive logic
    // FIXME indicate framing errors
    always_ff @(posedge clk) begin
        if (~resetn) begin
            state <= IDLE;
        end else begin
            unique case (state)
                IDLE: begin
                    timer <= '0;
                    if (serial.txd === rs232.SPACE)
                        state <= START;
                end
                START: begin
                    timer <= timer + 1;
                    count <= '0;
                    if (timer === '1)
                        state <= (rx.txd === rs232.SPACE) ? DATA : IDLE;
                end
                DATA: begin
                    timer <= timer + 1;
                    if (timer === '1) begin
                        count <= count + 1;
                        data <= {data[6:0], rx.txd};
                    end
                    if (count === 3'b110)
                        state <= STOP;
                end
                STOP: begin
                    timer <= timer + 1;
                    if (rx.txd === rs232.MARK)
                        state <= IDLE;
                end
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

    // Write logic
    // FIXME tdata shall not change until handshake
    always_ff @(posedge clk) begin
        if (~resetn) begin
            write.tdata  <= '0;
            write.tvalid <= 1'b0;
        end else begin
            if (write.tvalid && write.tready)
                write.tvalid <= 1'b0;
            if (state == STOP && rx.txd === rs232.MARK) begin
                write.tdata  <= data;
                write.tvalid <= 1'b1;
            end
        end
    end

endmodule
