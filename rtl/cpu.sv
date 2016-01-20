/*
 * Copyright (c) 2015, 2016 C. Brett Witherspoon
 *
 * See LICENSE for more details.
 */

/**
 * Module: cpu
 */
module cpu
    import core::addr_t;
    import core::ctrl_t;
    import core::ex_t;
    import core::fun_t;
    import core::imm_t;
    import core::inst_t;
    import core::id_t;
    import core::jmp_t;
    import core::mm_t;
    import core::op_t;
    import core::rs_t;
    import core::wb_t;
    import core::word_t;
(
    input  logic clk,
    input  logic rst,
    input  logic irq,
    axi.master   code,
    axi.master   data,
    axi.master   mmio
);
    /*
     * Interfaces
     */

    wire aresetn = ~rst;
    wire aclk = clk;

    axis #(.DATA_WIDTH($bits(id_t))) id (.*);

    axis #(.DATA_WIDTH($bits(ex_t))) ex (.*);

    axis #(.DATA_WIDTH($bits(mm_t))) mm (.*);

    axis #(.DATA_WIDTH($bits(wb_t))) wb (.*);

///////////////////////////////////////////////////////////////////////////////

    /*
     * Hazards
     */

    wire stall;
    wire flush;

    hazard hazard (
        .decode(id),
        .execute(ex),
        .memory(mm),
        .writeback(wb),
        .stall,
        .flush
    );

///////////////////////////////////////////////////////////////////////////////

    /*
     * Exceptions / Traps / Interrupts
     */

    wire invalid;
    wire trap = ~rst & (irq | invalid);


///////////////////////////////////////////////////////////////////////////////

    /*
     * Forwarding
     */

    rs_t rs1;
    rs_t rs2;

    forward forward (
        .decode(id),
        .execute(ex),
        .memory(mm),
        .writeback(wb),
        .rs1,
        .rs2
    );

///////////////////////////////////////////////////////////////////////////////

    /*
     * Fetch
     */

    wire branch;
    word_t target;

    fetch fetch (
        .branch,
        .target,
        .trap,
        .handler(core::KERN_BASE),
        .flush,
        .cache(code),
        .down(id)
    );

///////////////////////////////////////////////////////////////////////////////

    /*
     * Decode
     */

    addr_t rs1_addr;
    addr_t rs2_addr;
    word_t rs1_data;
    word_t rs2_data;
    word_t alu_data;
    word_t exe_data;
    word_t mem_data;

    logic  rd_en;
    addr_t rd_addr;
    word_t rd_data;

    // The output of the execute stage is available on the memory stream interface.
    mm_t exe;
    assign exe = mm_t'(mm.monitor.tdata);
    assign exe_data = exe.data.alu;

    regfile regfile (
        .clk,
        .rs1_addr,
        .rs2_addr,
        .rs1_data,
        .rs2_data,
        .rd_en,
        .rd_addr,
        .rd_data
    );

    decode decode (
        .stall,
        .rs1_sel(rs1),
        .rs2_sel(rs2),
        .alu_data,
        .exe_data,
        .mem_data,
        .rs1_data,
        .rs2_data,
        .rs1_addr,
        .rs2_addr,
        .invalid,
        .up(id),
        .down(ex)
    );


///////////////////////////////////////////////////////////////////////////////

    /*
     * Execute
     */

    execute execute (
        .branch,
        .target,
        .bypass(alu_data),
        .up(ex),
        .down(mm)
    );

///////////////////////////////////////////////////////////////////////////////

    /*
     * Memory
     */

    axi cache (.*);

    protect protect (.*);

    control #(
        .BASE(core::CODE_BASE),
        .SIZE(core::CODE_SIZE)
    ) control (
        .bypass(mem_data),
        .cache(cache),
        .up(mm),
        .down(wb)
    );

///////////////////////////////////////////////////////////////////////////////

    /*
     * Writeback
     */


    writeback writeback (
        .rd(rd_en),
        .rd_addr(rd_addr ),
        .rd_data(rd_data ),
        .up(wb)
    );

endmodule
