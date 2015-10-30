/**
 * Module: uart
 *
 * A UART controller.
 */
module uart (
    input logic clk,
    input logic resetn,
    rs232.dce   dce,
    axis.slave  slave,
    axis.master master
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
                    if (dce.txd === dce.SPACE)
                        state <= START;
                end
                START: begin
                    timer <= timer + 1;
                    count <= '0;
                    if (timer === '1)
                        state <= (dce.txd === dce.SPACE) ? DATA : IDLE;
                end
                DATA: begin
                    timer <= timer + 1;
                    if (timer === '1) begin
                        count <= count + 1;
                        data <= {data[6:0], dce.txd};
                    end
                    if (count === 3'b110)
                        state <= STOP;
                end
                STOP: begin
                    timer <= timer + 1;
                    if (dce.txd === dce.MARK)
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
            master.tdata  <= '0;
            master.tvalid <= 1'b0;
        end else begin
            if (master.tvalid && master.tready)
                master.tvalid <= 1'b0;
            if (state == STOP && dce.txd === dce.MARK) begin
                master.tdata  <= data;
                master.tvalid <= 1'b1;
            end
        end
    end

endmodule
