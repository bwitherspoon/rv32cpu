/*
 * Copyright (c) 2015-2018 C. Brett Witherspoon
 *
 * See LICENSE for more details.
 */

/**
 * Module: cpu
 */
module cpu
    import rv32::addr_t;
    import rv32::ctrl_t;
    import rv32::ex_t;
    import rv32::imm_t;
    import rv32::inst_t;
    import rv32::id_t;
    import rv32::mm_t;
    import rv32::op_t;
    import rv32::rs_t;
    import rv32::wb_t;
    import rv32::word_t;
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
    wire lock;

    hazard hazard (
        .decode(id),
        .execute(ex),
        .memory(mm),
        .writeback(wb),
        .stall,
        .lock
    );

///////////////////////////////////////////////////////////////////////////////

    /*
     * Exceptions / Traps / Interrupts
     */

    wire invalid;
    wire fault;
    wire trap = ~rst & (irq | invalid | fault);


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
        .aclk,
        .aresetn,
        .branch,
        .target,
        .trap,
        .handler(rv32::TRAP_ADDR),
        .stall,
        .cache(code),
        .sink(id)
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
    assign exe = mm_t'(mm.tdata);
    assign exe_data = exe.data.alu;

    // The output of the memory stage is available on the writeback stream interface.
    wb_t mem;
    assign mem = wb_t'(wb.tdata);
    assign mem_data = mem.data.rd.data;

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
        .lock,
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
        .source(id),
        .sink(ex)
    );


///////////////////////////////////////////////////////////////////////////////

    /*
     * Execute
     */

    execute execute (
        .branch,
        .target,
        .bypass(alu_data),
        .source(ex),
        .sink(mm)
    );

///////////////////////////////////////////////////////////////////////////////

    /*
     * Memory
     */

    axi cache (.*);

    arbitrate arbitrate (.cache(cache), .*);

    memory memory (
        .aclk,
        .aresetn,
        .cache(cache),
        .source(mm),
        .sink(wb)
    );

///////////////////////////////////////////////////////////////////////////////

    /*
     * Writeback
     */

    writeback writeback (
        .rd_load(rd_en),
        .rd_addr(rd_addr),
        .rd_data(rd_data),
        .source(wb)
    );

endmodule
