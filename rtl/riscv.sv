/**
 * Package: riscv
 */
package riscv;

    import opcode::opcode_t;
    import funct3::funct3_t;

    localparam WORD_WIDTH = 32;
    localparam REGS_ADDR_WIDTH = 5;
    localparam REGS_DATA_WIDTH = WORD_WIDTH;
    localparam IMEM_ADDR_WIDTH = 9;
    localparam IMEM_DATA_WIDTH = WORD_WIDTH;
    
    typedef union packed {
        struct packed {
            opcode_t     opcode;
            logic [24:0] operand;
        } generic;

        struct packed {
            opcode_t    opcode;
            logic [4:0] rd;
            funct3_t    funct3;
            logic [4:0] rs1;
            logic [4:0] rs2;
            logic [6:0] funct7;
        } r_type;

        struct packed {
            opcode_t    opcode;
            logic [4:0] rd;
            funct3_t    funct3;
            logic [4:0] rs1;
            logic       imm_0;
            logic [3:0] imm_4_1;
            logic [5:0] imm_10_5;
            logic       imm_11;
        } i_type;

        struct packed {
            opcode_t    opcode;
            logic       imm_0;
            logic [3:0] imm_4_1;
            funct3_t    funct3;
            logic [4:0] rs1;
            logic [4:0] rs2;
            logic [5:0] imm_10_5;
            logic       imm_11;
        } s_type;

        struct packed {
            opcode_t    opcode;
            logic       imm_11;
            logic [3:0] imm_4_1;
            funct3_t    funct3;
            logic [4:0] rs1;
            logic [4:0] rs2;
            logic [5:0] imm_10_5;
            logic       imm_12;
        } sb_type;

        struct packed {
            opcode_t     opcode;
            logic [4:0]  rd;
            logic [2:0]  imm_14_12;
            logic [4:0]  imm_19_15;
            logic [10:0] imm_30_20;
            logic        imm_31;
        } u_type;

        struct packed {
            opcode_t    opcode;
            logic [4:0] rd;
            logic [2:0] imm_14_12;
            logic [4:0] imm_19_15;
            logic       imm_11;
            logic [3:0] imm_4_1;
            logic [5:0] imm_10_5;
            logic       imm_20;
        } uj_type;
    } ir_t;

endpackage
