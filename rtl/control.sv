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
    // Internal control signal types
    typedef enum logic [2:0] {
        JMP_BR_NONE,
        JMP_BR_JAL,
        JMP_BR_BEQ,
        JMP_BR_BNE,
        JMP_BR_BLT,
        JMP_BR_BLTU,
        JMP_BR_BGE,
        JMP_BR_BGEU
    } jmp_br_t;

    typedef struct packed {
        logic     reg_en;
        mem_op_t  mem_op;
        logic     link_en;
        alu_op_t  alu_op;
        jmp_br_t  jmp_br;
        op1_sel_t op1_sel;
        op2_sel_t op2_sel;
    } ctrl_id_t;

    // Control signals for supported instructions
    localparam ctrl_id_t CTRL_INVALID = '{
        reg_en:  1'b0,
        mem_op:  LOAD_STORE_NONE,
        link_en: 1'bx,
        alu_op:  ALU_XXX,
        jmp_br:  JMP_BR_NONE,
        op1_sel: OP1_XXX,
        op2_sel: OP2_XXX
    };
    localparam ctrl_id_t CTRL_ADDI = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        link_en: 1'b0,
        alu_op:  ALU_ADD,
        jmp_br:  JMP_BR_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_I_IMM
    };
    localparam ctrl_id_t CTRL_LUI = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        link_en: 1'b0,
        alu_op:  ALU_OP2,
        jmp_br:  JMP_BR_NONE,
        op1_sel: OP1_XXX,
        op2_sel: OP2_U_IMM
    };
    localparam ctrl_id_t CTRL_AUIPC = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        link_en: 1'b0,
        alu_op:  ALU_ADD,
        jmp_br:  JMP_BR_NONE,
        op1_sel: OP1_PC,
        op2_sel: OP2_U_IMM
    };
    localparam ctrl_id_t CTRL_ADD = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        link_en: 1'b0,
        alu_op:  ALU_ADD,
        jmp_br:  JMP_BR_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_RS2
    };
    localparam ctrl_id_t CTRL_SUB = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        link_en: 1'b0,
        alu_op:  ALU_SUB,
        jmp_br:  JMP_BR_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_RS2
    };
    localparam ctrl_id_t CTRL_JAL = '{
        reg_en:  1'b1,
        mem_op:  LOAD_STORE_NONE,
        link_en: 1'b1,
        alu_op:  ALU_ADD,
        jmp_br:  JMP_BR_JAL,
        op1_sel: OP1_PC,
        op2_sel: OP2_J_IMM
    };
    localparam ctrl_id_t CTRL_SW = '{
        reg_en:  1'b0,
        mem_op:  STORE_WORD,
        link_en: 1'b0,
        alu_op:  ALU_ADD,
        jmp_br:  JMP_BR_NONE,
        op1_sel: OP1_RS1,
        op2_sel: OP2_S_IMM
    };
    localparam ctrl_id_t CTRL_SH = '{
            reg_en:  1'b0,
            mem_op:  STORE_HALF,
            link_en: 1'b0,
            alu_op:  ALU_ADD,
            jmp_br:  JMP_BR_NONE,
            op1_sel: OP1_RS1,
            op2_sel: OP2_S_IMM
    };
    localparam ctrl_id_t CTRL_SB = '{
            reg_en:  1'b0,
            mem_op:  STORE_BYTE,
            link_en: 1'b0,
            alu_op:  ALU_ADD,
            jmp_br:  JMP_BR_NONE,
            op1_sel: OP1_RS1,
            op2_sel: OP2_S_IMM
    };

    // Pipeline control signals
    ctrl_id_t id;

    struct packed {
        logic    reg_en;
        mem_op_t mem_op;
        logic    link_en;
        alu_op_t alu_op;
        jmp_br_t jmp_br;
    } ex;

    struct packed {
        logic    reg_en;
        mem_op_t mem_op;
    } mem;

    struct packed {
        logic reg_en;
    } wb;

    logic invalid;

    // Decode
    always_comb begin
        invalid = 1'b0;
        unique case (opcode)
            OPCODE_STORE:
                unique case (funct3)
                    FUNCT3_SW: id = CTRL_SW;
                    FUNCT3_SH: id = CTRL_SH;
                    FUNCT3_SB: id = CTRL_SB;
                    default: begin
                        $display("ERROR: Invalid funct3 in STORE instruction");
                        invalid = 1'b1;
                        id = CTRL_INVALID;
                    end
                endcase
            OPCODE_OP_IMM:
                unique case (funct3)
                    FUNCT3_ADDI: id = CTRL_ADDI;
                    default: begin
                        $display("ERROR: Invalid funct3 in OP_IMM instruction");
                        invalid = 1'b1;
                        id = CTRL_INVALID;
                    end
                endcase
            OPCODE_OP:
                unique case (funct3)
                    FUNCT3_ADD_SUB: id = (funct7[5]) ? CTRL_ADD : CTRL_SUB;
                    default: begin
                        $display("ERROR: Invalid funct3 in OP instruction");
                        invalid = 1'b1;
                        id = CTRL_INVALID;
                    end
                endcase
            OPCODE_LUI:   id = CTRL_LUI;
            OPCODE_AUIPC: id = CTRL_AUIPC;
            OPCODE_JAL:   id = CTRL_JAL;
            default: begin
                $display("ERROR: Invalid opcode in instruction");
                invalid = 1'b1;
                id = CTRL_INVALID;
            end
        endcase
    end

    // Execute
    wire jal  = ex.jmp_br == JMP_BR_JAL;
    wire beq  = ex.jmp_br == JMP_BR_BEQ  && eq;
    wire bne  = ex.jmp_br == JMP_BR_BEQ  && !eq;
    wire blt  = ex.jmp_br == JMP_BR_BLT  && lt;
    wire bltu = ex.jmp_br == JMP_BR_BLTU && ltu;
    wire bge  = ex.jmp_br == JMP_BR_BGE  && eq && !lt;
    wire bgeu = ex.jmp_br == JMP_BR_BLTU && eq && !ltu;

    wire jump_branch = jal | beq | bne | blt | bltu | bge | bgeu;

    always_ff @(posedge clk)
        if (~resetn) begin
            ex.reg_en <= 1'b0;
            ex.mem_op <= LOAD_STORE_NONE;
            ex.jmp_br <= JMP_BR_NONE;
        end else begin
            ex.reg_en  <= (jump_branch === 1'b1) ? 1'b0 : id.reg_en;
            ex.mem_op  <= (jump_branch === 1'b1) ? LOAD_STORE_NONE : id.mem_op;
            ex.link_en <= id.link_en;
            ex.alu_op  <= id.alu_op;
            ex.jmp_br  <= id.jmp_br;
        end

    // Memory
    always_ff @(posedge clk)
        if (~resetn) begin
            mem.reg_en <= 1'b0;
            mem.mem_op <= LOAD_STORE_NONE;
        end else begin
            mem.reg_en <= ex.reg_en;
            mem.mem_op <= ex.mem_op;
        end

    // Writeback
    always_ff @(posedge clk)
        if (~resetn)
            wb.reg_en <= 1'b0;
        else
            wb.reg_en <= mem.reg_en;

    // External control signals
    assign ctrl.reg_en  = wb.reg_en;
    assign ctrl.mem_op  = mem.mem_op;
    assign ctrl.link_en = ex.link_en;
    assign ctrl.alu_op  = ex.alu_op;
    assign ctrl.pc_sel  = (jump_branch === 1'b1) ? PC_ADDR : PC_NEXT;
    assign ctrl.ir_sel  = (jump_branch === 1'b1) ? IR_BUBBLE : IR_MEMORY;
    assign ctrl.op1_sel = id.op1_sel;
    assign ctrl.op2_sel = id.op2_sel;

endmodule
