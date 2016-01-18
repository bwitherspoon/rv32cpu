/*
 * Copyright 2016 C. Brett Witherspoon
 *
 * See LICENSE for more details.
 */

/**
 * Module: decode
 * 
 * Instruction decode module.
 * 
 * AXI interfaces must by synchronous with the processor. 
 */
module decode
    import core::addr_t;
    import core::ctrl_t;
    import core::ex_t;
    import core::id_t;
    import core::imm_t;
    import core::inst_t;
    import core::rs_t;
    import core::word_t;
(
    input  rs_t   rs1_sel,
    input  rs_t   rs2_sel,
    input  word_t alu_data,
    input  word_t exe_data,
    input  word_t mem_data,
    input  word_t rs1_data,
    input  word_t rs2_data,
    output addr_t rs1_addr,
    output addr_t rs2_addr,
    axis.slave    slave,
    axis.master   master
);
    id_t id;
    assign id = slave.tdata;

    word_t pc;
    assign pc = id.data.pc;

    inst_t ir;
    assign ir = id.data.ir;

    ex_t ex;
    assign master.tdata = ex;

    assign rs1_addr = ir.r.rs1;
    assign rs2_addr = ir.r.rs2;

    imm_t i_imm;
    imm_t s_imm;
    imm_t b_imm;
    imm_t u_imm;
    imm_t j_imm;

    assign i_imm = imm_t'(signed'(ir.i.imm_11_0));
    assign s_imm = imm_t'(signed'({ir.s.imm_11_5, ir.s.imm_4_0}));
    assign b_imm = imm_t'(signed'({ir.sb.imm_12, ir.sb.imm_11, ir.sb.imm_10_5, ir.sb.imm_4_1, 1'b0}));
    assign u_imm = (signed'({ir.u.imm_31_12, 12'd0})); // FIXME cast to imm_t 
    assign j_imm = imm_t'(signed'({ir.uj.imm_20, ir.uj.imm_19_12, ir.uj.imm_11, ir.uj.imm_10_1, 1'b0}));

    word_t rs1;
    word_t rs2;
    word_t op1;
    word_t op2;

    logic invalid;

    ctrl_t ctrl;

    // Control decoder
    control control (
        .opcode(ir.r.opcode),
        .funct3(ir.r.funct3),
        .funct7(ir.r.funct7),
        .invalid,
        .ctrl
    );

    // First source register forwarding
    always_comb
        unique case (rs1_sel)
            core::ALU: rs1 = alu_data;
            core::EXE: rs1 = exe_data;
            core::MEM: rs1 = mem_data;
            default:   rs1 = rs1_data;
        endcase

    // Second source register forwarding
   always_comb
        unique case (rs2_sel)
            core::ALU: rs2 = alu_data;
            core::EXE: rs2 = exe_data;
            core::MEM: rs2 = mem_data;
            default:   rs2 = rs2_data;
        endcase

    // First operand select
   always_comb
        unique case (ctrl.op1)
            core::PC: op1 = pc;
            default:  op1 = rs1_data;
        endcase

    // Second operand select
   always_comb
        unique case (ctrl.op2)
            core::I_IMM: op2 = i_imm;
            core::S_IMM: op2 = s_imm;
            core::B_IMM: op2 = b_imm;
            core::U_IMM: op2 = u_imm;
            core::J_IMM: op2 = j_imm;
            default:     op2 = rs2_data;
        endcase

    // Streams
    assign slave.tready = master.tready;

    always_ff @(posedge master.aclk)
        if (~master.aresetn) begin
            ex.ctrl.op <= core::NULL;
            ex.ctrl.jmp <= core::NONE;
        end else if (master.tready) begin
            ex.ctrl.op  <= (slave.tvalid) ? ctrl.op : core::NULL;
            ex.ctrl.fun <= ctrl.fun;
            ex.ctrl.jmp <= (slave.tvalid) ? ctrl.jmp : core::NONE;
            ex.data.pc  <= pc;
            ex.data.op1 <= op1;
            ex.data.op2 <= op2;
            ex.data.rs1 <= rs1;
            ex.data.rs2 <= rs2;
            ex.data.rd  <= ir.r.rd;
        end

    always_ff @(posedge master.aclk)
        if (~master.aresetn)
            master.tvalid <= '0;
        else if (slave.tvalid)
            master.tvalid <= '1;
        else
            master.tvalid <= '0;

endmodule : decode


