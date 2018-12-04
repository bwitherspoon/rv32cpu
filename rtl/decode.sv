/*
 * Copyright 2016-2018 C. Brett Witherspoon
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
    import rv32::addr_t;
    import rv32::ctrl_t;
    import rv32::ex_t;
    import rv32::id_t;
    import rv32::imm_t;
    import rv32::inst_t;
    import rv32::rs_t;
    import rv32::word_t;
(
    input  logic  lock,
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
    localparam ctrl_t NONE = '{
        op:  rv32::NONE,
        fn:  rv32::ANY,
        br:  rv32::NA,
        op1: rv32::XX,
        op2: rv32::XXX
    };
    localparam ctrl_t ADDI = '{
        op:  rv32::INTEGER,
        fn:  rv32::ADD,
        br:  rv32::NA,
        op1: rv32::RS1,
        op2: rv32::I_IMM
    };
    localparam ctrl_t SLTI = '{
        op:  rv32::INTEGER,
        fn:  rv32::SLT,
        br:  rv32::NA,
        op1: rv32::RS1,
        op2: rv32::I_IMM
    };
    localparam ctrl_t SLTIU = '{
        op:  rv32::INTEGER,
        fn:  rv32::SLTU,
        br:  rv32::NA,
        op1: rv32::RS1,
        op2: rv32::I_IMM
    };
    localparam ctrl_t ANDI = '{
        op:  rv32::INTEGER,
        fn:  rv32::AND,
        br:  rv32::NA,
        op1: rv32::RS1,
        op2: rv32::I_IMM
    };
    localparam ctrl_t ORI = '{
        op:  rv32::INTEGER,
        fn:  rv32::OR,
        br:  rv32::NA,
        op1: rv32::RS1,
        op2: rv32::I_IMM
    };
    localparam ctrl_t XORI = '{
        op:  rv32::INTEGER,
        fn:  rv32::XOR,
        br:  rv32::NA,
        op1: rv32::RS1,
        op2: rv32::I_IMM
    };
    localparam ctrl_t SLLI = '{
        op:  rv32::INTEGER,
        fn:  rv32::SLL,
        br:  rv32::NA,
        op1: rv32::RS1,
        op2: rv32::I_IMM
    };
    localparam ctrl_t SRLI = '{
        op:  rv32::INTEGER,
        fn:  rv32::SRL,
        br:  rv32::NA,
        op1: rv32::RS1,
        op2: rv32::I_IMM
    };
    localparam ctrl_t SRAI = '{
        op:  rv32::INTEGER,
        fn:  rv32::SRA,
        br:  rv32::NA,
        op1: rv32::RS1,
        op2: rv32::I_IMM
    };
    localparam ctrl_t LUI = '{
        op:  rv32::INTEGER,
        fn:  rv32::OP2,
        br:  rv32::NA,
        op1: rv32::XX,
        op2: rv32::U_IMM
    };
    localparam ctrl_t AUIPC = '{
        op:  rv32::INTEGER,
        fn:  rv32::ADD,
        br:  rv32::NA,
        op1: rv32::PC,
        op2: rv32::U_IMM
    };
    localparam ctrl_t ADD = '{
        op:  rv32::INTEGER,
        fn:  rv32::ADD,
        br:  rv32::NA,
        op1: rv32::RS1,
        op2: rv32::RS2
    };
    localparam ctrl_t SLT = '{
        op:  rv32::INTEGER,
        fn:  rv32::SLT,
        br:  rv32::NA,
        op1: rv32::RS1,
        op2: rv32::RS2
    };
    localparam ctrl_t SLTU = '{
        op:  rv32::INTEGER,
        fn:  rv32::SLTU,
        br:  rv32::NA,
        op1: rv32::RS1,
        op2: rv32::RS2
    };
    localparam ctrl_t AND = '{
        op:  rv32::INTEGER,
        fn:  rv32::AND,
        br:  rv32::NA,
        op1: rv32::RS1,
        op2: rv32::RS2
    };
    localparam ctrl_t OR = '{
        op:  rv32::INTEGER,
        fn:  rv32::OR,
        br:  rv32::NA,
        op1: rv32::RS1,
        op2: rv32::RS2
    };
    localparam ctrl_t XOR = '{
        op:  rv32::INTEGER,
        fn:  rv32::XOR,
        br:  rv32::NA,
        op1: rv32::RS1,
        op2: rv32::RS2
    };
    localparam ctrl_t SLL = '{
        op:  rv32::INTEGER,
        fn:  rv32::SLL,
        br:  rv32::NA,
        op1: rv32::RS1,
        op2: rv32::RS2
    };
    localparam ctrl_t SRL = '{
        op:  rv32::INTEGER,
        fn:  rv32::SRL,
        br:  rv32::NA,
        op1: rv32::RS1,
        op2: rv32::RS2
    };
    localparam ctrl_t SUB = '{
        op:  rv32::INTEGER,
        fn:  rv32::SUB,
        br:  rv32::NA,
        op1: rv32::RS1,
        op2: rv32::RS2
    };
    localparam ctrl_t SRA = '{
        op:  rv32::INTEGER,
        fn:  rv32::SRA,
        br:  rv32::NA,
        op1: rv32::RS1,
        op2: rv32::RS2
    };
    localparam ctrl_t JAL = '{
        op:  rv32::JUMP,
        fn:  rv32::ADD,
        br:  rv32::JAL,
        op1: rv32::PC,
        op2: rv32::J_IMM
    };
    localparam ctrl_t JALR = '{
        op:  rv32::JUMP,
        fn:  rv32::ADD,
        br:  rv32::JAL,
        op1: rv32::RS1,
        op2: rv32::I_IMM
    };
    localparam ctrl_t BEQ = '{
        op:  rv32::BRANCH,
        fn:  rv32::ADD,
        br:  rv32::BEQ,
        op1: rv32::PC,
        op2: rv32::B_IMM
    };
    localparam ctrl_t BNE = '{
        op:  rv32::BRANCH,
        fn:  rv32::ADD,
        br:  rv32::BNE,
        op1: rv32::PC,
        op2: rv32::B_IMM
    };
    localparam ctrl_t BLT = '{
        op:  rv32::BRANCH,
        fn:  rv32::ADD,
        br:  rv32::BLT,
        op1: rv32::PC,
        op2: rv32::B_IMM
    };
    localparam ctrl_t BLTU = '{
        op:  rv32::BRANCH,
        fn:  rv32::ADD,
        br:  rv32::BLTU,
        op1: rv32::PC,
        op2: rv32::B_IMM
    };
    localparam ctrl_t BGE = '{
        op:  rv32::BRANCH,
        fn:  rv32::ADD,
        br:  rv32::BGE,
        op1: rv32::PC,
        op2: rv32::B_IMM
    };
    localparam ctrl_t BGEU = '{
        op:  rv32::BRANCH,
        fn:  rv32::ADD,
        br:  rv32::BGEU,
        op1: rv32::PC,
        op2: rv32::B_IMM
    };
    localparam ctrl_t LW = '{
        op:  rv32::LOAD_WORD,
        fn:  rv32::ADD,
        br:  rv32::NA,
        op1: rv32::RS1,
        op2: rv32::I_IMM
    };
    localparam ctrl_t LH = '{
        op:  rv32::LOAD_HALF,
        fn:  rv32::ADD,
        br:  rv32::NA,
        op1: rv32::RS1,
        op2: rv32::I_IMM
    };
    localparam ctrl_t LHU = '{
        op:  rv32::LOAD_HALF_UNSIGNED,
        fn:  rv32::ADD,
        br:  rv32::NA,
        op1: rv32::RS1,
        op2: rv32::I_IMM
    };
    localparam ctrl_t LB = '{
        op:  rv32::LOAD_BYTE,
        fn:  rv32::ADD,
        br:  rv32::NA,
        op1: rv32::RS1,
        op2: rv32::I_IMM
    };
    localparam ctrl_t LBU = '{
        op:  rv32::LOAD_BYTE_UNSIGNED,
        fn:  rv32::ADD,
        br:  rv32::NA,
        op1: rv32::RS1,
        op2: rv32::I_IMM
    };
    localparam ctrl_t SW = '{
        op:  rv32::STORE_WORD,
        fn:  rv32::ADD,
        br:  rv32::NA,
        op1: rv32::RS1,
        op2: rv32::S_IMM
    };
    localparam ctrl_t SH = '{
        op:  rv32::STORE_HALF,
        fn:  rv32::ADD,
        br:  rv32::NA,
        op1: rv32::RS1,
        op2: rv32::S_IMM
    };
    localparam ctrl_t SB = '{
        op:  rv32::STORE_BYTE,
        fn:  rv32::ADD,
        br:  rv32::NA,
        op1: rv32::RS1,
        op2: rv32::S_IMM
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
                    funct3::ADD:   ctrl = ADDI;
                    funct3::SLL:   ctrl = SLLI;
                    funct3::SLT:   ctrl = SLTI;
                    funct3::SLTIU: ctrl = SLTIU;
                    funct3::XOR:   ctrl = XORI;
                    funct3::SRL:   ctrl = (ir.r.funct7[5]) ? SRAI : SRLI;
                    funct3::OR:    ctrl = ORI;
                    funct3::AND:   ctrl = ANDI;
                    default:       ctrl = NONE;
                endcase
            opcodes::OP:
                unique case (ir.r.funct3)
                    funct3::ADD:  ctrl = (ir.r.funct7[5]) ? SUB : ADD;
                    funct3::SLL:  ctrl = SLL;
                    funct3::SLT:  ctrl = SLT;
                    funct3::SLTU: ctrl = SLTU;
                    funct3::XOR:  ctrl = XOR;
                    funct3::SRL:  ctrl = (ir.r.funct7[5]) ? SRA : SRL;
                    funct3::OR:   ctrl = OR;
                    funct3::AND:  ctrl = AND;
                    default:      ctrl = NONE;
                endcase
            opcodes::LUI:   ctrl = LUI;
            opcodes::AUIPC: ctrl = AUIPC;
            opcodes::JAL:   ctrl = JAL;
            opcodes::JALR:  ctrl = JALR;
            opcodes::BRANCH:
                unique case (ir.r.funct3)
                    funct3::BEQ:  ctrl = BEQ;
                    funct3::BNE:  ctrl = BNE;
                    funct3::BLT:  ctrl = BLT;
                    funct3::BLTU: ctrl = BLTU;
                    funct3::BGE:  ctrl = BGE;
                    funct3::BGEU: ctrl = BGEU;
                    default:      ctrl = NONE;
                endcase
            opcodes::LOAD:
                unique case (ir.r.funct3)
                    funct3::LW:  ctrl = LW;
                    funct3::LH:  ctrl = LH;
                    funct3::LHU: ctrl = LHU;
                    funct3::LB:  ctrl = LB;
                    funct3::LBU: ctrl = LBU;
                    default:     ctrl = NONE;
                endcase
            opcodes::STORE:
                unique case (ir.r.funct3)
                    funct3::SB: ctrl = SB;
                    funct3::SH: ctrl = SH;
                    funct3::SW: ctrl = SW;
                    default:    ctrl = NONE;
                endcase
            default:
                ctrl = NONE;
        endcase
    end : control

    // First source register forwarding
    always_comb
        unique case (rs1_sel)
            rv32::ALU: rs1 = alu_data;
            rv32::EXE: rs1 = exe_data;
            rv32::MEM: rs1 = mem_data;
            default:   rs1 = rs1_data;
        endcase

    // Second source register forwarding
   always_comb
        unique case (rs2_sel)
            rv32::ALU: rs2 = alu_data;
            rv32::EXE: rs2 = exe_data;
            rv32::MEM: rs2 = mem_data;
            default:   rs2 = rs2_data;
        endcase

    // First operand select
   always_comb
        unique case (ctrl.op1)
            rv32::PC: op1 = pc;
            default:  op1 = rs1;
        endcase

    // Second operand select
   always_comb
        unique case (ctrl.op2)
            rv32::I_IMM: op2 = i_imm;
            rv32::S_IMM: op2 = s_imm;
            rv32::B_IMM: op2 = b_imm;
            rv32::U_IMM: op2 = u_imm;
            rv32::J_IMM: op2 = j_imm;
            default:     op2 = rs2;
        endcase

    // AXI
    always_ff @(posedge sink.aclk)
        if (sink.tready) begin
            ex.ctrl.op  <= ctrl.op;
            ex.ctrl.fn  <= ctrl.fn;
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
        else if (source.tvalid & source.tready)
            sink.tvalid <= '1;
        else if (sink.tvalid & sink.tready)
            sink.tvalid <= '0;

    assign source.tready = sink.tready & ~lock;

    // Error
    assign invalid = ctrl.op == rv32::NONE & source.tvalid;

endmodule : decode
