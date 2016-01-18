/*
 * Copyright (c) 2015, C. Brett Witherspoon
 */

/**
 * Module: control
 */
module control
    import core::opcode_t;
    import core::funct3_t;
    import core::funct7_t;
    import core::ctrl_t;
(
     input  opcode_t opcode,
     input  funct3_t funct3,
     input  funct7_t funct7,
     output logic    invalid,
     output ctrl_t   ctrl
);
    localparam ctrl_t KILL = '{
        op:  core::NULL,
        fun: core::ANY,
        jmp: core::NONE,
        op1: core::XX,
        op2: core::XXX
    };
    localparam ctrl_t ADDI = '{
        op:  core::REGISTER,
        fun: core::ADD,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t SLTI = '{
       op:  core::REGISTER,
       fun: core::SLT,
       jmp: core::NONE,
       op1: core::RS1,
       op2: core::I_IMM
    };
    localparam ctrl_t SLTIU = '{
        op:  core::REGISTER,
        fun: core::SLTU,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t ANDI = '{
        op:  core::REGISTER,
        fun: core::AND,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t ORI = '{
        op:  core::REGISTER,
        fun: core::OR,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t XORI = '{
        op:  core::REGISTER,
        fun: core::XOR,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t SLLI = '{
        op: core::REGISTER,
        fun: core::SLL,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t SRLI = '{
        op:  core::REGISTER,
        fun: core::SRL,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t SRAI = '{
        op:  core::REGISTER,
        fun: core::SRA,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t LUI = '{
        op:  core::REGISTER,
        fun: core::OP2,
        jmp: core::NONE,
        op1: core::XX,
        op2: core::U_IMM
    };
    localparam ctrl_t AUIPC = '{
        op:  core::REGISTER,
        fun: core::ADD,
        jmp: core::NONE,
        op1: core::PC,
        op2: core::U_IMM
    };
    localparam ctrl_t ADD = '{
        op:  core::REGISTER,
        fun: core::AND,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::RS2
    };
    localparam ctrl_t SLT = '{
        op:  core::REGISTER,
        fun: core::SLT,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::RS2
    };
    localparam ctrl_t SLTU = '{
        op:  core::REGISTER,
        fun: core::SLTU,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::RS2
    };
    localparam ctrl_t AND = '{
        op:  core::REGISTER,
        fun: core::AND,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::RS2
    };
    localparam ctrl_t OR = '{
        op:  core::REGISTER,
        fun: core::OR,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::RS2
    };
    localparam ctrl_t XOR = '{
        op:  core::REGISTER,
        fun: core::XOR,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::RS2
    };
    localparam ctrl_t SLL = '{
        op:  core::REGISTER,
        fun: core::SLL,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::RS2
    };
    localparam ctrl_t SRL = '{
        op: core::REGISTER,
        fun: core::SRL,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::RS2
    };
    localparam ctrl_t SUB = '{
        op:  core::REGISTER,
        fun: core::SUB,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::RS2
    };
    localparam ctrl_t SRA = '{
        op:  core::REGISTER,
        fun: core::SRA,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::RS2
    };
    localparam ctrl_t JAL = '{
        op:  core::JUMP_OR_BRANCH,
        fun: core::ADD,
        jmp: core::JAL_OR_JALR,
        op1: core::PC,
        op2: core::J_IMM
    };
    localparam ctrl_t JALR = '{
        op:  core::JUMP_OR_BRANCH,
        fun: core::ADD,
        jmp: core::JAL_OR_JALR,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t BEQ = '{
        op:  core::JUMP_OR_BRANCH,
        fun: core::ADD,
        jmp: core::BEQ,
        op1: core::PC,
        op2: core::B_IMM
    };
    localparam ctrl_t BNE = '{
        op:  core::JUMP_OR_BRANCH,
        fun: core::ADD,
        jmp: core::BNE,
        op1: core::PC,
        op2: core::B_IMM
    };
    localparam ctrl_t BLT = '{
        op:  core::JUMP_OR_BRANCH,
        fun: core::ADD,
        jmp: core::BLT,
        op1: core::PC,
        op2: core::B_IMM
    };
    localparam ctrl_t BLTU = '{
        op:  core::JUMP_OR_BRANCH,
        fun: core::ADD,
        jmp: core::BLTU,
        op1: core::PC,
        op2: core::B_IMM
    };
    localparam ctrl_t BGE = '{
        op:  core::JUMP_OR_BRANCH,
        fun: core::ADD,
        jmp: core::BGE,
        op1: core::PC,
        op2: core::B_IMM
    };
    localparam ctrl_t BGEU = '{
        op: core::JUMP_OR_BRANCH,
        fun: core::ADD,
        jmp: core::BGEU,
        op1: core::PC,
        op2: core::B_IMM
    };
    localparam ctrl_t LW = '{
        op:  core::LOAD_WORD,
        fun: core::ADD,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t LH = '{
        op:  core::LOAD_HALF,
        fun: core::ADD,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t LHU = '{
        op:  core::LOAD_HALF_UNSIGNED,
        fun: core::ADD,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t LB = '{
        op:  core::LOAD_BYTE,
        fun: core::ADD,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t LBU = '{
        op: core::LOAD_BYTE_UNSIGNED,
        fun:  core::ADD,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t SW = '{
        op:  core::STORE_WORD,
        fun: core::ADD,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::S_IMM
    };
    localparam ctrl_t SH = '{
        op:  core::STORE_HALF,
        fun: core::ADD,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::S_IMM
    };
    localparam ctrl_t SB = '{
        op:  core::STORE_BYTE,
        fun: core::ADD,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::S_IMM
    };

    always_comb begin : decoder
        invalid = 1'b0;
        unique case (opcode)
            core::OP_IMM:
                unique case (funct3)
                    core::BEQ_LB_SB_ADD_SUB: ctrl = ADDI;
                    core::BNE_LH_SH_SLL:     ctrl = SLLI;
                    core::LW_SW_SLT:         ctrl = SLTI;
                    core::SLTU_SLTIU:        ctrl = SLTIU;
                    core::BLT_LBU_XOR:       ctrl = XORI;
                    core::BGE_LHU_SRL_SRA:   ctrl = (funct7[5]) ? SRAI : SRLI;
                    core::BLTU_OR:           ctrl = ORI;
                    core::BGEU_AND:          ctrl = ANDI;
                    default: begin
                        invalid = 1'b1;
                        ctrl = KILL;
                    end
                endcase
            core::OP:
                unique case (funct3)
                    core::BEQ_LB_SB_ADD_SUB: ctrl = (funct7[5]) ? SUB : ADD;
                    core::BNE_LH_SH_SLL:     ctrl = SLL;
                    core::LW_SW_SLT:         ctrl = SLT;
                    core::SLTU_SLTIU:        ctrl = SLTU;
                    core::BLT_LBU_XOR:       ctrl = XOR;
                    core::BGE_LHU_SRL_SRA:   ctrl = (funct7[5]) ? SRA : SRL;
                    core::BLTU_OR:           ctrl = OR;
                    core::BGEU_AND:          ctrl = AND;
                    default: begin
                        invalid = 1'b1;
                        ctrl = KILL;
                    end
                endcase
            core::LUI:   ctrl = LUI;
            core::AUIPC: ctrl = AUIPC;
            core::JAL:   ctrl = JAL;
            core::JALR:  ctrl = JALR;
            core::BRANCH:
                unique case (funct3)
                    core::BEQ_LB_SB_ADD_SUB: ctrl = BEQ;
                    core::BNE_LH_SH_SLL:     ctrl = BNE;
                    core::BLT_LBU_XOR :      ctrl = BLT;
                    core::BLTU_OR:           ctrl = BLTU;
                    core::BGE_LHU_SRL_SRA:   ctrl = BGE;
                    core::BGEU_AND:          ctrl = BGEU;
                    default: begin
                        invalid = 1'b1;
                        ctrl = KILL;
                    end
                endcase
            core::LOAD:
                unique case (funct3)
                    core::LW_SW_SLT:         ctrl = LW;
                    core::BNE_LH_SH_SLL:     ctrl = LH;
                    core::BGE_LHU_SRL_SRA:   ctrl = LHU;
                    core::BEQ_LB_SB_ADD_SUB: ctrl = LB;
                    core::BLT_LBU_XOR:       ctrl = LBU;
                    default: begin
                        invalid = 1'b1;
                        ctrl = KILL;
                    end
                endcase
            core::STORE:
                unique case (funct3)
                    core::BEQ_LB_SB_ADD_SUB: ctrl = SB;
                    core::BNE_LH_SH_SLL:     ctrl = SH;
                    core::LW_SW_SLT:         ctrl = SW;
                    default: begin
                        invalid = 1'b1;
                        ctrl = KILL;
                    end
                endcase
            default: begin
                invalid = 1'b1;
                ctrl = KILL;
            end
        endcase
    end : decoder

endmodule
