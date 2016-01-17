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
     input  logic    valid,
     output logic    invalid,
     output ctrl_t   ctrl
);
    localparam ctrl_t NOP = '{
        fun: core::NULL,
        op:  core::ANY,
        jmp: core::NONE,
        op1: core::XX,
        op2: core::XXX
    };
    localparam ctrl_t ADDI = '{
        fun: core::REGISTER,
        op:  core::ADD,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t SLTI = '{
       fun: core::REGISTER,
       op:  core::SLT,
       jmp: core::NONE,
       op1: core::RS1,
       op2: core::I_IMM
    };
    localparam ctrl_t SLTIU = '{
        fun: core::REGISTER,
        op:  core::SLTU,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t ANDI = '{
        fun: core::REGISTER,
        op:  core::AND,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t ORI = '{
        fun: core::REGISTER,
        op:  core::OR,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t XORI = '{
        fun: core::REGISTER,
        op:  core::XOR,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t SLLI = '{
        fun: core::REGISTER,
        op:  core::SLL,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t SRLI = '{
        fun: core::REGISTER,
        op:  core::SRL,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t SRAI = '{
        fun: core::REGISTER,
        op:  core::SRA,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t LUI = '{
        fun: core::REGISTER,
        op:  core::OP2,
        jmp: core::NONE,
        op1: core::XX,
        op2: core::U_IMM
    };
    localparam ctrl_t AUIPC = '{
        fun: core::REGISTER,
        op:  core::ADD,
        jmp: core::NONE,
        op1: core::PC,
        op2: core::U_IMM
    };
    localparam ctrl_t ADD = '{
        fun: core::REGISTER,
        op:  core::AND,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::RS2
    };
    localparam ctrl_t SLT = '{
        fun: core::REGISTER,
        op:  core::SLT,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::RS2
    };
    localparam ctrl_t SLTU = '{
        fun: core::REGISTER,
        op:  core::SLTU,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::RS2
    };
    localparam ctrl_t AND = '{
        fun: core::REGISTER,
        op:  core::AND,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::RS2
    };
    localparam ctrl_t OR = '{
        fun: core::REGISTER,
        op:  core::OR,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::RS2
    };
    localparam ctrl_t XOR = '{
        fun: core::REGISTER,
        op:  core::XOR,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::RS2
    };
    localparam ctrl_t SLL = '{
        fun: core::REGISTER,
        op:  core::SLL,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::RS2
    };
    localparam ctrl_t SRL = '{
        fun: core::REGISTER,
        op:  core::SRL,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::RS2
    };
    localparam ctrl_t SUB = '{
        fun: core::REGISTER,
        op:  core::SUB,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::RS2
    };
    localparam ctrl_t SRA = '{
        fun: core::REGISTER,
        op:  core::SRA,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::RS2
    };
    localparam ctrl_t JAL = '{
        fun: core::JUMP_OR_BRANCH,
        op:  core::ADD,
        jmp: core::JAL_OR_JALR,
        op1: core::PC,
        op2: core::J_IMM
    };
    localparam ctrl_t JALR = '{
        fun: core::JUMP_OR_BRANCH,
        op:  core::ADD,
        jmp: core::JAL_OR_JALR,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t BEQ = '{
        fun: core::JUMP_OR_BRANCH,
        op:  core::ADD,
        jmp: core::BEQ,
        op1: core::PC,
        op2: core::B_IMM
    };
    localparam ctrl_t BNE = '{
        fun: core::JUMP_OR_BRANCH,
        op:  core::ADD,
        jmp: core::BNE,
        op1: core::PC,
        op2: core::B_IMM
    };
    localparam ctrl_t BLT = '{
        fun: core::JUMP_OR_BRANCH,
        op:  core::ADD,
        jmp: core::BLT,
        op1: core::PC,
        op2: core::B_IMM
    };
    localparam ctrl_t BLTU = '{
        fun: core::JUMP_OR_BRANCH,
        op:  core::ADD,
        jmp: core::BLTU,
        op1: core::PC,
        op2: core::B_IMM
    };
    localparam ctrl_t BGE = '{
        fun: core::JUMP_OR_BRANCH,
        op:  core::ADD,
        jmp: core::BGE,
        op1: core::PC,
        op2: core::B_IMM
    };
    localparam ctrl_t BGEU = '{
        fun: core::JUMP_OR_BRANCH,
        op:  core::ADD,
        jmp: core::BGEU,
        op1: core::PC,
        op2: core::B_IMM
    };
    localparam ctrl_t LW = '{
        fun: core::LOAD_WORD,
        op:  core::ADD,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t LH = '{
        fun: core::LOAD_HALF,
        op:  core::ADD,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t LHU = '{
        fun: core::LOAD_HALF_UNSIGNED,
        op:  core::ADD,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t LB = '{
        fun: core::LOAD_BYTE,
        op:  core::ADD,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t LBU = '{
        fun: core::LOAD_BYTE_UNSIGNED,
        op:  core::ADD,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::I_IMM
    };
    localparam ctrl_t SW = '{
        fun: core::STORE_WORD,
        op:  core::ADD,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::S_IMM
    };
    localparam ctrl_t SH = '{
        fun: core::STORE_HALF,
        op:  core::ADD,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::S_IMM
    };
    localparam ctrl_t SB = '{
        fun: core::STORE_BYTE,
        op:  core::ADD,
        jmp: core::NONE,
        op1: core::RS1,
        op2: core::S_IMM
    };

    always_comb begin : decoder
        invalid = 1'b0;
        if (~valid)
            ctrl = NOP;
        else
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
                            ctrl = NOP;
                        end
                    endcase
                core::OP:
                    unique case (funct3)
                        core::BEQ_LB_SB_ADD_SUB: ctrl = (funct7[5]) ? SUB : ADD;
                        core::BNE_LH_SH_SLL:     ctrl = SLL;
                        core::LW_SW_SLT:         ctrl = SLT;
                        core::SLTU:              ctrl = SLTU;
                        core::BLT_LBU_XOR:       ctrl = XOR;
                        core::BGE_LHU_SRL_SRA:   ctrl = (funct7[5]) ? SRA : SRL;
                        core::BLTU_OR:           ctrl = OR;
                        core::BGEU_AND:          ctrl = AND;
                        default: begin
                            invalid = 1'b1;
                            ctrl = NOP;
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
                            ctrl = NOP;
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
                            ctrl = NOP;
                        end
                    endcase
                core::STORE:
                    unique case (funct3)
                        core::BEQ_LB_SB_ADD_SUB: ctrl = SB;
                        core::BNE_LH_SH_SLL:     ctrl = SH;
                        core::LW_SW_SLT:         ctrl = SW;
                        default: begin
                            invalid = 1'b1;
                            ctrl = NOP;
                        end
                    endcase
                default: begin
                    invalid = 1'b1;
                    ctrl = NOP;
                end
            endcase
    end : decoder

endmodule
