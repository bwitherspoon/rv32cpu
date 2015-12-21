/*
 * control.sv
 */

import riscv::*;

/**
 * Module: control
 */
module control (
     input  logic    clk,
     input  logic    resetn,
     input  opcode_t opcode,
     input  funct3_t funct3,
     input  funct7_t funct7,
     input  logic    eq,
     input  logic    lt,
     input  logic    ltu,
     output ctrl_t   ctrl
);
    // Types
    typedef enum logic [2:0] {
        JMP_OP_NONE,
        JMP_OP_JAL,
        JMP_OP_BEQ,
        JMP_OP_BNE,
        JMP_OP_BLT,
        JMP_OP_BLTU,
        JMP_OP_BGE,
        JMP_OP_BGEU
    } jmp_op_t;

    typedef struct packed {
        logic     reg_en;
        mem_op_t  mem_op;
        logic     link_en;
        alu_op_t  alu_op;
        jmp_op_t  jmp_op;
        op1_sel_t op1_sel;
        op2_sel_t op2_sel;
    } ctrl_id_t;

    // Parameters
    localparam ctrl_id_t CTRL_NOP = '{
        reg_en:  1'b0,
        mem_op:  LOAD_STORE_NONE,
        link_en: 1'bx,
        alu_op:  ALU_XXX,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_XXX,
        op2_sel: OP2_XXX
    };
    localparam ctrl_id_t CTRL_ADDI = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        link_en: 1'b0,
        alu_op:  ALU_ADD,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_I_IMM
    };
    localparam ctrl_id_t CTRL_LUI = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        link_en: 1'b0,
        alu_op:  ALU_OP2,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_XXX,
        op2_sel: OP2_U_IMM
    };
    localparam ctrl_id_t CTRL_AUIPC = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        link_en: 1'b0,
        alu_op:  ALU_ADD,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_PC,
        op2_sel: OP2_U_IMM
    };
    localparam ctrl_id_t CTRL_ADD = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        link_en: 1'b0,
        alu_op:  ALU_ADD,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_RS2
    };
    localparam ctrl_id_t CTRL_SUB = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        link_en: 1'b0,
        alu_op:  ALU_SUB,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_RS2
    };
    localparam ctrl_id_t CTRL_JAL = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        link_en: 1'b1,
        alu_op:  ALU_ADD,
        jmp_op:  JMP_OP_JAL,
        op1_sel: OP1_PC,
        op2_sel: OP2_J_IMM
    };
    localparam ctrl_id_t CTRL_JALR = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        link_en: 1'b1,
        alu_op:  ALU_ADD,
        jmp_op:  JMP_OP_JAL,
        op1_sel: OP1_RS1,
        op2_sel: OP2_I_IMM
    };
    localparam ctrl_id_t CTRL_BEQ = '{
        reg_en:  1'b0,
        mem_op:  LOAD_STORE_NONE,
        link_en: 1'b0,
        alu_op:  ALU_ADD,
        jmp_op:  JMP_OP_BEQ,
        op1_sel: OP1_PC,
        op2_sel: OP2_B_IMM
    };
    localparam ctrl_id_t CTRL_BNE = '{
        reg_en:  1'b0,
        mem_op:  LOAD_STORE_NONE,
        link_en: 1'b0,
        alu_op:  ALU_ADD,
        jmp_op:  JMP_OP_BNE,
        op1_sel: OP1_PC,
        op2_sel: OP2_B_IMM
    };
    localparam ctrl_id_t CTRL_BLT = '{
        reg_en:  1'b0,
        mem_op:  LOAD_STORE_NONE,
        link_en: 1'b0,
        alu_op:  ALU_ADD,
        jmp_op:  JMP_OP_BLT,
        op1_sel: OP1_PC,
        op2_sel: OP2_B_IMM
    };
    localparam ctrl_id_t CTRL_BLTU = '{
        reg_en:  1'b0,
        mem_op:  LOAD_STORE_NONE,
        link_en: 1'b0,
        alu_op:  ALU_ADD,
        jmp_op:  JMP_OP_BLTU,
        op1_sel: OP1_PC,
        op2_sel: OP2_B_IMM
    };
    localparam ctrl_id_t CTRL_BGE = '{
        reg_en:  1'b0,
        mem_op:  LOAD_STORE_NONE,
        link_en: 1'b0,
        alu_op:  ALU_ADD,
        jmp_op:  JMP_OP_BGE,
        op1_sel: OP1_PC,
        op2_sel: OP2_B_IMM
    };
    localparam ctrl_id_t CTRL_BGEU = '{
        reg_en:  1'b0,
        mem_op:  LOAD_STORE_NONE,
        link_en: 1'b0,
        alu_op:  ALU_ADD,
        jmp_op:  JMP_OP_BGEU,
        op1_sel: OP1_PC,
        op2_sel: OP2_B_IMM
    };

    localparam ctrl_id_t CTRL_SW = '{
        reg_en:  1'b0,
        mem_op:  STORE_WORD,
        link_en: 1'b0,
        alu_op:  ALU_ADD,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_S_IMM
    };
    localparam ctrl_id_t CTRL_SH = '{
        reg_en:  1'b0,
        mem_op:  STORE_HALF,
        link_en: 1'b0,
        alu_op:  ALU_ADD,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_S_IMM
    };
    localparam ctrl_id_t CTRL_SB = '{
        reg_en:  1'b0,
        mem_op:  STORE_BYTE,
        link_en: 1'b0,
        alu_op:  ALU_ADD,
        jmp_op:  JMP_OP_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_S_IMM
    };

    // Internal signals
    ctrl_id_t id;

    struct packed {
        logic    reg_en;
        mem_op_t mem_op;
        logic    link_en;
        alu_op_t alu_op;
        jmp_op_t jmp_op;
        logic    jmp;
        logic    br;
    } ex;

    struct packed {
        logic    reg_en;
        mem_op_t mem_op;
        logic jmp;
        logic br;
    } mem;

    struct packed {
        logic reg_en;
    } wb;

    wire beq  = ex.jmp_op == JMP_OP_BEQ  & eq;
    wire bne  = ex.jmp_op == JMP_OP_BNE  & ~eq;
    wire blt  = ex.jmp_op == JMP_OP_BLT  & lt;
    wire bltu = ex.jmp_op == JMP_OP_BLTU & ltu;
    wire bge  = ex.jmp_op == JMP_OP_BGE  & (eq | ~lt);
    wire bgeu = ex.jmp_op == JMP_OP_BGEU & (eq | ~ltu);

    assign ex.br = beq | bne | blt | bltu | bge | bgeu;

    assign ex.jmp = ex.jmp_op == JMP_OP_JAL;

    // External signals
    assign ctrl.reg_en  = wb.reg_en;
    assign ctrl.mem_op  = mem.mem_op;
    assign ctrl.link_en = ex.link_en;
    assign ctrl.alu_op  = ex.alu_op;
    assign ctrl.pc_sel  = (ex.jmp | ex.br) ? PC_ADDR : PC_NEXT;
    assign ctrl.op1_sel = id.op1_sel;
    assign ctrl.op2_sel = id.op2_sel;

    logic invalid;

    // Stages
    always_comb begin : decode
        invalid = 1'b0;
        if (ex.jmp | mem.jmp)
            id = CTRL_NOP;
        else begin
            unique case (opcode)
                OPCODE_OP_IMM:
                    unique case (funct3)
                        FUNCT3_ADDI: id = CTRL_ADDI;
                        default: begin
                            $display("ERROR: Invalid funct3 in OP_IMM");
                            invalid = 1'b1;
                            id = CTRL_NOP;
                        end
                    endcase
                OPCODE_OP:
                    unique case (funct3)
                        FUNCT3_ADD_SUB: id = (funct7[5]) ? CTRL_ADD : CTRL_SUB;
                        default: begin
                            $display("ERROR: Invalid funct3 in OP");
                            invalid = 1'b1;
                            id = CTRL_NOP;
                        end
                    endcase
                OPCODE_LUI:   id = CTRL_LUI;
                OPCODE_AUIPC: id = CTRL_AUIPC;
                OPCODE_JAL:   id = CTRL_JAL;
                OPCODE_JALR:  id = CTRL_JALR;
                OPCODE_BRANCH:
                    unique case (funct3)
                        FUNCT3_BEQ:  id = CTRL_BEQ;
                        FUNCT3_BNE:  id = CTRL_BNE;
                        FUNCT3_BLT:  id = CTRL_BLT;
                        FUNCT3_BLTU: id = CTRL_BLTU;
                        FUNCT3_BGE:  id = CTRL_BGE;
                        FUNCT3_BGEU: id = CTRL_BGEU;
                        default: begin
                            $display("ERROR: Invalid funct3 in BRANCH");
                            invalid = 1'b1;
                            id = CTRL_NOP;
                        end
                    endcase
                OPCODE_STORE:
                    unique case (funct3)
                        FUNCT3_SW: id = CTRL_SW;
                        FUNCT3_SH: id = CTRL_SH;
                        FUNCT3_SB: id = CTRL_SB;
                        default: begin
                            $display("ERROR: Invalid funct3 in STORE");
                            invalid = 1'b1;
                            id = CTRL_NOP;
                        end
                    endcase
                default: begin
                    $display("ERROR: Invalid opcode");
                    invalid = 1'b1;
                    id = CTRL_NOP;
                end
            endcase
        end
    end : decode

    always_ff @(posedge clk) begin : execute
        if (~resetn) begin
            ex.reg_en <= 1'b0;
            ex.mem_op <= LOAD_STORE_NONE;
            ex.jmp_op <= JMP_OP_NONE;
        end else begin
            ex.reg_en  <= (ex.br | mem.br) ? 1'b0 : id.reg_en;
            ex.mem_op  <= (ex.br | mem.br) ? LOAD_STORE_NONE : id.mem_op;
            ex.link_en <= id.link_en;
            ex.alu_op  <= id.alu_op;
            ex.jmp_op  <= (ex.br | mem.br) ? JMP_OP_NONE : id.jmp_op;
        end
    end : execute

    always_ff @(posedge clk) begin : memory
        if (~resetn) begin
            mem.reg_en <= 1'b0;
            mem.mem_op <= LOAD_STORE_NONE;
            mem.jmp    <= 1'b0;
            mem.br     <= 1'b0;
        end else begin
            mem.reg_en <= ex.reg_en;
            mem.mem_op <= ex.mem_op;
            mem.jmp    <= ex.jmp;
            mem.br     <= ex.br;
        end
    end : memory

    always_ff @(posedge clk) begin : writeback
        if (~resetn)
            wb.reg_en <= 1'b0;
        else
            wb.reg_en <= mem.reg_en;
    end : writeback

endmodule
