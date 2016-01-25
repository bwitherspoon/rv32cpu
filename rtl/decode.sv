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
    output logic  invalid,
    axis.slave    source,
    axis.master   sink
);
    localparam ctrl_t INVAL = '{
        op:  core::INVALID,
        fun: core::ANY,
        br:  core::IGNORE,
        op1: core::XX,
        op2: core::XXX
    };
    localparam ctrl_t ADDI = '{
        op:  core::INTEGER,
        fun: core::ADD,
        br:  core::IGNORE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t SLTI = '{
        op:  core::INTEGER,
        fun: core::SLT,
        br:  core::IGNORE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t SLTIU = '{
        op:  core::INTEGER,
        fun: core::SLTU,
        br:  core::IGNORE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t ANDI = '{
        op:  core::INTEGER,
        fun: core::AND,
        br:  core::IGNORE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t ORI = '{
        op:  core::INTEGER,
        fun: core::OR,
        br:  core::IGNORE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t XORI = '{
        op:  core::INTEGER,
        fun: core::XOR,
        br:  core::IGNORE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t SLLI = '{
        op:  core::INTEGER,
        fun: core::SLL,
        br:  core::IGNORE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t SRLI = '{
        op:  core::INTEGER,
        fun: core::SRL,
        br:  core::IGNORE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t SRAI = '{
        op:  core::INTEGER,
        fun: core::SRA,
        br:  core::IGNORE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t LUI = '{
        op:  core::INTEGER,
        fun: core::OP2,
        br:  core::IGNORE,
        op1: core::XX,
        op2: core::U_IMM
    };
    localparam ctrl_t AUIPC = '{
        op:  core::INTEGER,
        fun: core::ADD,
        br:  core::IGNORE,
        op1: core::PC,
        op2: core::U_IMM
    };
    localparam ctrl_t ADD = '{
        op:  core::INTEGER,
        fun: core::AND,
        br:  core::IGNORE,
        op1: core::RS1,
        op2: core::RS2
    };
    localparam ctrl_t SLT = '{
        op:  core::INTEGER,
        fun: core::SLT,
        br:  core::IGNORE,
        op1: core::RS1,
        op2: core::RS2
    };
    localparam ctrl_t SLTU = '{
        op:  core::INTEGER,
        fun: core::SLTU,
        br:  core::IGNORE,
        op1: core::RS1,
        op2: core::RS2
    };
    localparam ctrl_t AND = '{
        op:  core::INTEGER,
        fun: core::AND,
        br:  core::IGNORE,
        op1: core::RS1,
        op2: core::RS2
    };
    localparam ctrl_t OR = '{
        op:  core::INTEGER,
        fun: core::OR,
        br:  core::IGNORE,
        op1: core::RS1,
        op2: core::RS2
    };
    localparam ctrl_t XOR = '{
        op:  core::INTEGER,
        fun: core::XOR,
        br:  core::IGNORE,
        op1: core::RS1,
        op2: core::RS2
    };
    localparam ctrl_t SLL = '{
        op:  core::INTEGER,
        fun: core::SLL,
        br:  core::IGNORE,
        op1: core::RS1,
        op2: core::RS2
    };
    localparam ctrl_t SRL = '{
        op:  core::INTEGER,
        fun: core::SRL,
        br:  core::IGNORE,
        op1: core::RS1,
        op2: core::RS2
    };
    localparam ctrl_t SUB = '{
        op:  core::INTEGER,
        fun: core::SUB,
        br:  core::IGNORE,
        op1: core::RS1,
        op2: core::RS2
    };
    localparam ctrl_t SRA = '{
        op:  core::INTEGER,
        fun: core::SRA,
        br:  core::IGNORE,
        op1: core::RS1,
        op2: core::RS2
    };
    localparam ctrl_t JAL = '{
        op:  core::JUMP,
        fun: core::ADD,
        br:  core::JAL_JALR,
        op1: core::PC,
        op2: core::J_IMM
    };
    localparam ctrl_t JALR = '{
        op:  core::JUMP,
        fun: core::ADD,
        br:  core::JAL_JALR,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t BEQ = '{
        op:  core::BRANCH,
        fun: core::ADD,
        br:  core::BEQ,
        op1: core::PC,
        op2: core::B_IMM
    };
    localparam ctrl_t BNE = '{
        op:  core::BRANCH,
        fun: core::ADD,
        br:  core::BNE,
        op1: core::PC,
        op2: core::B_IMM
    };
    localparam ctrl_t BLT = '{
        op:  core::BRANCH,
        fun: core::ADD,
        br:  core::BLT,
        op1: core::PC,
        op2: core::B_IMM
    };
    localparam ctrl_t BLTU = '{
        op:  core::BRANCH,
        fun: core::ADD,
        br:  core::BLTU,
        op1: core::PC,
        op2: core::B_IMM
    };
    localparam ctrl_t BGE = '{
        op:  core::BRANCH,
        fun: core::ADD,
        br:  core::BGE,
        op1: core::PC,
        op2: core::B_IMM
    };
    localparam ctrl_t BGEU = '{
        op:  core::BRANCH,
        fun: core::ADD,
        br:  core::BGEU,
        op1: core::PC,
        op2: core::B_IMM
    };
    localparam ctrl_t LW = '{
        op:  core::LOAD_WORD,
        fun: core::ADD,
        br:  core::IGNORE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t LH = '{
        op:  core::LOAD_HALF,
        fun: core::ADD,
        br:  core::IGNORE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t LHU = '{
        op:  core::LOAD_HALF_UNSIGNED,
        fun: core::ADD,
        br:  core::IGNORE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t LB = '{
        op:  core::LOAD_BYTE,
        fun: core::ADD,
        br:  core::IGNORE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t LBU = '{
        op:  core::LOAD_BYTE_UNSIGNED,
        fun: core::ADD,
        br:  core::IGNORE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t SW = '{
        op:  core::STORE_WORD,
        fun: core::ADD,
        br:  core::IGNORE,
        op1: core::RS1,
        op2: core::S_IMM
    };
    localparam ctrl_t SH = '{
        op:  core::STORE_HALF,
        fun: core::ADD,
        br:  core::IGNORE,
        op1: core::RS1,
        op2: core::S_IMM
    };
    localparam ctrl_t SB = '{
        op:  core::STORE_BYTE,
        fun: core::ADD,
        br:  core::IGNORE,
        op1: core::RS1,
        op2: core::S_IMM
    };

    id_t id;
    ex_t ex;

    word_t pc;
    inst_t ir;

    ctrl_t ctrl;

    assign id = source.tdata;
    assign sink.tdata = ex;

    assign pc = id.data.pc;
    assign ir = id.data.ir;

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

    // Control decoder
    always_comb begin : control
        unique case (ir.r.opcode)
            opcodes::OP_IMM:
                unique case (ir.r.funct3)
                    core::BEQ_LB_SB_ADD_SUB: ctrl = ADDI;
                    core::BNE_LH_SH_SLL:     ctrl = SLLI;
                    core::LW_SW_SLT:         ctrl = SLTI;
                    core::SLTU_SLTIU:        ctrl = SLTIU;
                    core::BLT_LBU_XOR:       ctrl = XORI;
                    core::BGE_LHU_SRL_SRA:   ctrl = (ir.r.funct7[5]) ? SRAI : SRLI;
                    core::BLTU_OR:           ctrl = ORI;
                    core::BGEU_AND:          ctrl = ANDI;
                    default:                 ctrl = INVAL;
                endcase
            opcodes::OP:
                unique case (ir.r.funct3)
                    core::BEQ_LB_SB_ADD_SUB: ctrl = (ir.r.funct7[5]) ? SUB : ADD;
                    core::BNE_LH_SH_SLL:     ctrl = SLL;
                    core::LW_SW_SLT:         ctrl = SLT;
                    core::SLTU_SLTIU:        ctrl = SLTU;
                    core::BLT_LBU_XOR:       ctrl = XOR;
                    core::BGE_LHU_SRL_SRA:   ctrl = (ir.r.funct7[5]) ? SRA : SRL;
                    core::BLTU_OR:           ctrl = OR;
                    core::BGEU_AND:          ctrl = AND;
                    default:                 ctrl = INVAL;
                endcase
            opcodes::LUI:   ctrl = LUI;
            opcodes::AUIPC: ctrl = AUIPC;
            opcodes::JAL:   ctrl = JAL;
            opcodes::JALR:  ctrl = JALR;
            opcodes::BRANCH:
                unique case (ir.r.funct3)
                    core::BEQ_LB_SB_ADD_SUB: ctrl = BEQ;
                    core::BNE_LH_SH_SLL:     ctrl = BNE;
                    core::BLT_LBU_XOR :      ctrl = BLT;
                    core::BLTU_OR:           ctrl = BLTU;
                    core::BGE_LHU_SRL_SRA:   ctrl = BGE;
                    core::BGEU_AND:          ctrl = BGEU;
                    default:                 ctrl = INVAL;
                endcase
            opcodes::LOAD:
                unique case (ir.r.funct3)
                    core::LW_SW_SLT:         ctrl = LW;
                    core::BNE_LH_SH_SLL:     ctrl = LH;
                    core::BGE_LHU_SRL_SRA:   ctrl = LHU;
                    core::BEQ_LB_SB_ADD_SUB: ctrl = LB;
                    core::BLT_LBU_XOR:       ctrl = LBU;
                    default:                 ctrl = INVAL;
                endcase
            opcodes::STORE:
                unique case (ir.r.funct3)
                    core::BEQ_LB_SB_ADD_SUB: ctrl = SB;
                    core::BNE_LH_SH_SLL:     ctrl = SH;
                    core::LW_SW_SLT:         ctrl = SW;
                    default:                 ctrl = INVAL;
                endcase
            default:
                ctrl = INVAL;
        endcase
    end : control

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
            default:  op1 = rs1;
        endcase

    // Second operand select
   always_comb
        unique case (ctrl.op2)
            core::I_IMM: op2 = i_imm;
            core::S_IMM: op2 = s_imm;
            core::B_IMM: op2 = b_imm;
            core::U_IMM: op2 = u_imm;
            core::J_IMM: op2 = j_imm;
            default:     op2 = rs2;
        endcase

    // AXI
    always_ff @(posedge sink.aclk)
        if (~sink.aresetn) begin
            ex.ctrl.op <= core::NONE;
            ex.ctrl.br <= core::IGNORE;
            ex.data.rd <= '0;
        end else if (sink.tready) begin
            ex.ctrl.op  <= ctrl.op;
            ex.ctrl.fun <= ctrl.fun;
            ex.ctrl.br  <= ctrl.br;
            ex.data.pc  <= pc;
            ex.data.op1 <= op1;
            ex.data.op2 <= op2;
            ex.data.rs1 <= rs1;
            ex.data.rs2 <= rs2;
            ex.data.rd  <= ir.r.rd;
        end

    always_ff @(posedge sink.aclk)
        if (~sink.aresetn)
            sink.tvalid <= '0;
        else if (source.tvalid)
            sink.tvalid <= '1;
        else if (sink.tvalid & sink.tready)
            sink.tvalid <= '0;

    assign source.tready = sink.tready;

    // Error
    assign invalid = ctrl.op == core::INVALID & source.tvalid;

endmodule : decode

