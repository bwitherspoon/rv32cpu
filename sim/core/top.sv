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

        $monitor("%6g: t0=%H,t1=%H,t2=%H,t3=%H,t4=%H,t5=%H,M[128]=%H", $time,
                 core.regfile.regs[5], core.regfile.regs[6],
                 core.regfile.regs[7], core.regfile.regs[28],
                 core.regfile.regs[29], core.regfile.regs[30],
                 core.memory.ram.mem[128]);


        reset();
        repeat (30) @(posedge clk);
        $finish;
    end

endmodule


