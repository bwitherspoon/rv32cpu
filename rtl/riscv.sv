/**
 * Package: riscv
 */
package riscv;

    import opcode::opcode_t;
    import funct3::funct3_t;
    import funct7::funct7_t;

    localparam WORD_WIDTH = 32;
    localparam REGS_ADDR_WIDTH = 5;
    localparam REGS_DATA_WIDTH = WORD_WIDTH;
    localparam IMEM_ADDR_WIDTH = 9;
    localparam IMEM_DATA_WIDTH = WORD_WIDTH;

    typedef logic [WORD_WIDTH-1:0]      word_t;
    typedef logic [IMEM_ADDR_WIDTH-1:0] pc_t;

    typedef enum logic [3:0] {
        ADD  = 'b0000,
        SLL  = 'b0001,
        SLT  = 'b0010,
        SLTU = 'b0011,
        XOR  = 'b0100,
        SRL  = 'b0101,
        OR   = 'b0110,
        AND  = 'b0111,
        SUB  = 'b1000,
        SRA  = 'b1101
    } funct_t;

    typedef logic [4:0] shamt_t;

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
            funct7_t    funct7;
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
