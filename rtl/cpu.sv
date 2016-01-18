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
    input  logic reset,
    input  logic interrupt,
    axi.master   code,
    axi.master   data,
    axi.master   peripheral
);
    wire resetn = ~reset;
    wire aresetn = ~reset;
    wire aclk = clk;

///////////////////////////////////////////////////////////////////////////////

    /*
     * Interfaces
     */

    axis #(
        .DATA_WIDTH($bits(id_t)),
        .ID_WIDTH(0),
        .DEST_WIDTH(0),
        .USER_WIDTH(0)
    ) id (.*);

    axis #(
        .DATA_WIDTH($bits(ex_t)),
        .ID_WIDTH(0),
        .DEST_WIDTH(0),
        .USER_WIDTH(0)
    ) ex (.*);

    axis #(
        .DATA_WIDTH($bits(mm_t)),
        .ID_WIDTH(0),
        .DEST_WIDTH(0),
        .USER_WIDTH(0)
    ) mm (.*);

    axis #(
        .DATA_WIDTH($bits(wb_t)),
        .ID_WIDTH(0),
        .DEST_WIDTH(0),
        .USER_WIDTH(0)
    ) wb (.*);

///////////////////////////////////////////////////////////////////////////////

    /*
     * Hazards
     */

    // TODO store -> load

    //wire branch = ex.ctrl.branch | ex.ctrl.jump;

    // Bubble after jump to wait for address
    //wire jump = ctrl.jmp == core::JAL_OR_JALR;

    // Bubble after load to account for load latency
    //wire load = core::is_load(ctrl.fun);

    // A bubble prevents the PC from advancing and inserts NOPs
    //wire bubble = load | jump;

    //wire idle;

    // A stall locks the entier pipeline and bubbles
    //wire stall = ~idle;

///////////////////////////////////////////////////////////////////////////////

    /*
     * Forwarding
     */

    // FIXME clean up this mess
//    always_comb
//        if (id.data.rs1_addr == ex.data.reg_addr
//            && id.data.rs1_addr != '0
//            && ex.ctrl.fun == core::REGISTER)
//            id.ctrl.rs1 = core::ALU;
//        else if (id.data.rs1_addr == mem.data.reg_addr
//                 && id.data.rs1_addr != '0
//                 && mem.ctrl.fun == core::REGISTER)
//            id.ctrl.rs1 = core::MEM;
//        else if (id.data.rs1_addr == mem.data.reg_addr
//                 && id.data.rs1_addr != '0
//                 && mem.ctrl.load == '1)
//            id.ctrl.rs1 = core::RAM;
//        else
//            id.ctrl.rs1 = core::REG;
//
//    always_comb
//        if (id.data.rs2_addr == ex.data.reg_addr
//            && id.data.rs2_addr != '0
//            && ex.ctrl.fun == core::REGISTER)
//            id.ctrl.rs2 = core::ALU;
//        else if (id.data.rs2_addr == mem.data.reg_addr
//                 && id.data.rs2_addr != '0
//                 && mem.ctrl.fun == core::REGISTER)
//            id.ctrl.rs2 = core::MEM;
//        else if (id.data.rs2_addr == mem.data.reg_addr
//                 && id.data.rs2_addr != '0
//                 && mem.ctrl.load == '1)
//            id.ctrl.rs2 = core::RAM;
//        else
//            id.ctrl.rs2 = core::REG;

///////////////////////////////////////////////////////////////////////////////

    /*
     * Exceptions / Traps / Interrupts
     */

    wire invalid;

    wire trap = ~reset & (interrupt | invalid);


///////////////////////////////////////////////////////////////////////////////

    /*
     * Fetch
     */

    wire branch;
    word_t target;

    fetch fetch (
        .clk,
        .reset(~resetn),
        .branch,
        .target,
        .trap,
        .handler(core::KERN_BASE),
        .pipe(id),
        .code(code)
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
        .rs1_sel(core::REG),
        .rs2_sel(core::REG),
        .alu_data,
        .exe_data,
        .mem_data,
        .rs1_data,
        .rs2_data,
        .rs1_addr,
        .rs2_addr,
        .slave(id),
        .master(ex)
    );


///////////////////////////////////////////////////////////////////////////////

    /*
     * Execute
     */

    execute execute (
        .branch,
        .target,
        .bypass(alu_data),
        .slave(ex),
        .master(mm)
    );

///////////////////////////////////////////////////////////////////////////////

    /*
     * Memory
     */

    memory #(
        .BASE(core::CODE_BASE),
        .SIZE(core::CODE_SIZE)
    ) memory (
        .bypass(mem_data),
        .cache(data),
        .slave(mm),
        .master(wb)
    );

///////////////////////////////////////////////////////////////////////////////

    /*
     * Writeback
     */


    writeback writeback (
        .rd(rd_en),
        .rd_addr(rd_addr ),
        .rd_data(rd_data ),
        .slave(wb)
    );

endmodule
