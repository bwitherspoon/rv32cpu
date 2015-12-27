/*
 * Copyright (c) 2015, C. Brett Witherspoon
 */

import riscv::*;

/**
 * Module: control
 */
module control (
     input  opcode_t opcode,
     input  funct3_t funct3,
     input  funct7_t funct7,
     input  logic    stall,
     output logic    invalid,
     output ctrl_t   ctrl
);

    localparam ctrl_t CTRL_NOP = '{
        reg_en:  1'b0,
        mem_op:  LOAD_STORE_NONE,
        alu_op:  ALU_XXX,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_XXX,
        op2_sel: OP2_XXX
    };
    localparam ctrl_t CTRL_ADDI = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        alu_op:  ALU_ADD,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_I_IMM
    };
    localparam ctrl_t CTRL_SLTI = '{
       reg_en:  1'b1,
       mem_op:  LOAD_STORE_NONE,
       alu_op:  ALU_SLT,
       jmp_op:  JMP_OP_NONE,
       op1_sel: OP1_RS1,
       op2_sel: OP2_I_IMM
    };
    localparam ctrl_t CTRL_SLTIU = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        alu_op:  ALU_SLTU,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_I_IMM
    };
    localparam ctrl_t CTRL_ANDI = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        alu_op:  ALU_AND,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_I_IMM
    };
    localparam ctrl_t CTRL_ORI = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        alu_op:  ALU_OR,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_I_IMM
    };
    localparam ctrl_t CTRL_XORI = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        alu_op:  ALU_XOR,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_I_IMM
    };
    localparam ctrl_t CTRL_SLLI = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        alu_op:  ALU_SLL,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_I_IMM
    };
    localparam ctrl_t CTRL_SRLI = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        alu_op:  ALU_SRL,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_I_IMM
    };
    localparam ctrl_t CTRL_SRAI = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        alu_op:  ALU_SRA,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_I_IMM
    };
    localparam ctrl_t CTRL_LUI = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        alu_op:  ALU_OP2,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_XXX,
        op2_sel: OP2_U_IMM
    };
    localparam ctrl_t CTRL_AUIPC = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        alu_op:  ALU_ADD,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_PC,
        op2_sel: OP2_U_IMM
    };
    localparam ctrl_t CTRL_ADD = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        alu_op:  ALU_ADD,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_RS2
    };
    localparam ctrl_t CTRL_SLT = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        alu_op:  ALU_SLT,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_RS2
    };
    localparam ctrl_t CTRL_SLTU = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        alu_op:  ALU_SLTU,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_RS2
    };
    localparam ctrl_t CTRL_AND = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        alu_op:  ALU_AND,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_RS2
    };
    localparam ctrl_t CTRL_OR = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        alu_op:  ALU_OR,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_RS2
    };
    localparam ctrl_t CTRL_XOR = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        alu_op:  ALU_XOR,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_RS2
    };
    localparam ctrl_t CTRL_SLL = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        alu_op:  ALU_SLL,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_RS2
    };
    localparam ctrl_t CTRL_SRL = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        alu_op:  ALU_SRL,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_RS2
    };
    localparam ctrl_t CTRL_SUB = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        alu_op:  ALU_SUB,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_RS2
    };
    localparam ctrl_t CTRL_SRA = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        alu_op:  ALU_SRA,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_RS2
    };
    localparam ctrl_t CTRL_JAL = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        alu_op:  ALU_ADD,
        jmp_op:  JMP_OP_JAL,
        op1_sel: OP1_PC,
        op2_sel: OP2_J_IMM
    };
    localparam ctrl_t CTRL_JALR = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        alu_op:  ALU_ADD,
        jmp_op:  JMP_OP_JAL,
        op1_sel: OP1_RS1,
        op2_sel: OP2_I_IMM
    };
    localparam ctrl_t CTRL_BEQ = '{
        reg_en:  1'b0,
        mem_op:  LOAD_STORE_NONE,
        alu_op:  ALU_ADD,
        jmp_op:  JMP_OP_BEQ,
        op1_sel: OP1_PC,
        op2_sel: OP2_B_IMM
    };
    localparam ctrl_t CTRL_BNE = '{
        reg_en:  1'b0,
        mem_op:  LOAD_STORE_NONE,
        alu_op:  ALU_ADD,
        jmp_op:  JMP_OP_BNE,
        op1_sel: OP1_PC,
        op2_sel: OP2_B_IMM
    };
    localparam ctrl_t CTRL_BLT = '{
        reg_en:  1'b0,
        mem_op:  LOAD_STORE_NONE,
        alu_op:  ALU_ADD,
        jmp_op:  JMP_OP_BLT,
        op1_sel: OP1_PC,
        op2_sel: OP2_B_IMM
    };
    localparam ctrl_t CTRL_BLTU = '{
        reg_en:  1'b0,
        mem_op:  LOAD_STORE_NONE,
        alu_op:  ALU_ADD,
        jmp_op:  JMP_OP_BLTU,
        op1_sel: OP1_PC,
        op2_sel: OP2_B_IMM
    };
    localparam ctrl_t CTRL_BGE = '{
        reg_en:  1'b0,
        mem_op:  LOAD_STORE_NONE,
        alu_op:  ALU_ADD,
        jmp_op:  JMP_OP_BGE,
        op1_sel: OP1_PC,
        op2_sel: OP2_B_IMM
    };
    localparam ctrl_t CTRL_BGEU = '{
        reg_en:  1'b0,
        mem_op:  LOAD_STORE_NONE,
        alu_op:  ALU_ADD,
        jmp_op:  JMP_OP_BGEU,
        op1_sel: OP1_PC,
        op2_sel: OP2_B_IMM
    };
    localparam ctrl_t CTRL_LW = '{
        reg_en:  1'b1,
        mem_op:  LOAD_WORD,
        alu_op:  ALU_ADD,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_I_IMM
    };
    localparam ctrl_t CTRL_LH = '{
        reg_en:  1'b1,
        mem_op:  LOAD_HALF,
        alu_op:  ALU_ADD,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_I_IMM
    };
    localparam ctrl_t CTRL_LHU = '{
        reg_en:  1'b1,
        mem_op:  LOAD_HALF_UNSIGNED,
        alu_op:  ALU_ADD,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_I_IMM
    };
    localparam ctrl_t CTRL_LB = '{
        reg_en:  1'b1,
        mem_op:  LOAD_BYTE,
        alu_op:  ALU_ADD,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_I_IMM
    };
    localparam ctrl_t CTRL_LBU = '{
        reg_en:  1'b1,
        mem_op:  LOAD_BYTE_UNSIGNED,
        alu_op:  ALU_ADD,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_I_IMM
    };
    localparam ctrl_t CTRL_SW = '{
        reg_en:  1'b0,
        mem_op:  STORE_WORD,
        alu_op:  ALU_ADD,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_S_IMM
    };
    localparam ctrl_t CTRL_SH = '{
        reg_en:  1'b0,
        mem_op:  STORE_HALF,
        alu_op:  ALU_ADD,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_S_IMM
    };
    localparam ctrl_t CTRL_SB = '{
        reg_en:  1'b0,
        mem_op:  STORE_BYTE,
        alu_op:  ALU_ADD,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_S_IMM
    };

    initial $timeformat(-9, 0, " ns", 10);

    always_comb begin : decode
        invalid = 1'b0;
        if (stall)
            ctrl = CTRL_NOP;
        else begin
            unique case (opcode)
                OPCODE_OP_IMM:
                    unique case (funct3)
                        FUNCT3_ADDI:      ctrl = CTRL_ADDI;
                        FUNCT3_SLTI:      ctrl = CTRL_SLTI;
                        FUNCT3_SLTIU:     ctrl = CTRL_SLTIU;
                        FUNCT3_XORI:      ctrl = CTRL_XORI;
                        FUNCT3_SRLI_SRAI: ctrl = (funct7[5]) ? CTRL_SRAI : CTRL_SRLI;
                        FUNCT3_ORI:       ctrl = CTRL_ORI;
                        FUNCT3_ANDI:      ctrl = CTRL_ANDI;
                        FUNCT3_SLLI:      ctrl = CTRL_SLLI;
                        default: begin
                            $display("%t: ERROR: Invalid funct3 in OP_IMM", $time);
                            invalid = 1'b1;
                            ctrl = CTRL_NOP;
                        end
                    endcase
                OPCODE_OP:
                    unique case (funct3)
                        FUNCT3_ADD_SUB: ctrl = (funct7[5]) ? CTRL_ADD : CTRL_SUB;
                        FUNCT3_SLL:     ctrl = CTRL_SLL;
                        FUNCT3_SLT:     ctrl = CTRL_SLT;
                        FUNCT3_SLTU:    ctrl = CTRL_SLTU;
                        FUNCT3_XOR:     ctrl = CTRL_XOR;
                        FUNCT3_SRL_SRA: ctrl = (funct7[5]) ? CTRL_SRA : CTRL_SRL;
                        FUNCT3_OR:      ctrl = CTRL_OR;
                        FUNCT3_AND:     ctrl = CTRL_AND;
                        default: begin
                            $display("%t: ERROR: Invalid funct3 in OP", $time);
                            invalid = 1'b1;
                            ctrl = CTRL_NOP;
                        end
                    endcase
                OPCODE_LUI:   ctrl = CTRL_LUI;
                OPCODE_AUIPC: ctrl = CTRL_AUIPC;
                OPCODE_JAL:   ctrl = CTRL_JAL;
                OPCODE_JALR:  ctrl = CTRL_JALR;
                OPCODE_BRANCH:
                    unique case (funct3)
                        FUNCT3_BEQ:  ctrl = CTRL_BEQ;
                        FUNCT3_BNE:  ctrl = CTRL_BNE;
                        FUNCT3_BLT:  ctrl = CTRL_BLT;
                        FUNCT3_BLTU: ctrl = CTRL_BLTU;
                        FUNCT3_BGE:  ctrl = CTRL_BGE;
                        FUNCT3_BGEU: ctrl = CTRL_BGEU;
                        default: begin
                            $display("%t: ERROR: Invalid funct3 in BRANCH", $time);
                            invalid = 1'b1;
                            ctrl = CTRL_NOP;
                        end
                    endcase
                OPCODE_LOAD:
                    unique case (funct3)
                        FUNCT3_LW:  ctrl = CTRL_LW;
                        FUNCT3_LH:  ctrl = CTRL_LH;
                        FUNCT3_LHU: ctrl = CTRL_LHU;
                        FUNCT3_LB:  ctrl = CTRL_LB;
                        FUNCT3_LBU: ctrl = CTRL_LBU;
                        default: begin
                            $display("%t: ERROR: Invalid width in LOAD", $time);
                            invalid = 1'b1;
                            ctrl = CTRL_NOP;
                        end
                    endcase
                OPCODE_STORE:
                    unique case (funct3)
                        FUNCT3_SW: ctrl = CTRL_SW;
                        FUNCT3_SH: ctrl = CTRL_SH;
                        FUNCT3_SB: ctrl = CTRL_SB;
                        default: begin
                            $display("%t: ERROR: Invalid width in STORE", $time);
                            invalid = 1'b1;
                            ctrl = CTRL_NOP;
                        end
                    endcase
                default: begin
                    $display("%t: ERROR: Invalid opcode: %b", $time, opcode);
                    invalid = 1'b1;
                    ctrl = CTRL_NOP;
                end
            endcase
        end
    end : decode

endmodule
