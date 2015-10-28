package rv32i;
    localparam logic [2:0] FUNCT3_JALR  = 'b000;
    localparam logic [2:0] FUNCT3_BEQ   = 'b000;
    localparam logic [2:0] FUNCT3_BNE   = 'b001;
    localparam logic [2:0] FUNCT3_BLT   = 'b100;
    localparam logic [2:0] FUNCT3_BGE   = 'b101;
    localparam logic [2:0] FUNCT3_BLTU  = 'b110;
    localparam logic [2:0] FUNCT3_BGEU  = 'b111;
    localparam logic [2:0] FUNCT3_LB    = 'b000;
    localparam logic [2:0] FUNCT3_LH    = 'b001;
    localparam logic [2:0] FUNCT3_LW    = 'b010;
    localparam logic [2:0] FUNCT3_LBU   = 'b100;
    localparam logic [2:0] FUNCT3_LHU   = 'b101;
    localparam logic [2:0] FUNCT3_SB    = 'b000;
    localparam logic [2:0] FUNCT3_SH    = 'b001;
    localparam logic [2:0] FUNCT3_SW    = 'b010;
    localparam logic [2:0] FUNCT3_ADDI  = 'b000;
    localparam logic [2:0] FUNCT3_SLTI  = 'b010;
    localparam logic [2:0] FUNCT3_SLTIU = 'b011;
    localparam logic [2:0] FUNCT3_XORI  = 'b100;
    localparam logic [2:0] FUNCT3_ORI   = 'b110;
    localparam logic [2:0] FUNCT3_ANDI  = 'b111;
    localparam logic [2:0] FUNCT3_SLLI  = 'b001;
    localparam logic [2:0] FUNCT3_SLRI  = 'b101;
    localparam logic [2:0] FUNCT3_SRAI  = 'b101;

    localparam logic [6:0] OPCODE_LOAD      = 'b0000011;
    localparam logic [6:0] OPCODE_LOAD_FP   = 'b0000111;
    localparam logic [6:0] OPCODE_CUSTOM_0  = 'b0001011;
    localparam logic [6:0] OPCODE_MISC_MEM  = 'b0001111;
    localparam logic [6:0] OPCODE_OP_IMM    = 'b0010011;
    localparam logic [6:0] OPCODE_AUIPC     = 'b0010111;
    localparam logic [6:0] OPCODE_OP_IMM_32 = 'b0011011;
    localparam logic [6:0] OPCODE_STORE     = 'b0100011;
    localparam logic [6:0] OPCODE_STORE_FP  = 'b0100111;
    localparam logic [6:0] OPCODE_CUSTOM_1  = 'b0101011;
    localparam logic [6:0] OPCODE_AMO       = 'b0101111;
    localparam logic [6:0] OPCODE_OP        = 'b0110011;
    localparam logic [6:0] OPCODE_LUI       = 'b0110111;
    localparam logic [6:0] OPCODE_OP_32     = 'b0111011;
    localparam logic [6:0] OPCODE_MADD      = 'b1000011;
    localparam logic [6:0] OPCODE_MSUB      = 'b1000111;
    localparam logic [6:0] OPCODE_NMSUB     = 'b1001011;
    localparam logic [6:0] OPCODE_NMADD     = 'b1001111;
    localparam logic [6:0] OPCODE_OP_FP     = 'b1010011;
    localparam logic [6:0] OPCODE_CUSTOM_2  = 'b1011011;
    localparam logic [6:0] OPCODE_BRANCH    = 'b1100011;
    localparam logic [6:0] OPCODE_JALR      = 'b1100111;
    localparam logic [6:0] OPCODE_JAL       = 'b1101111;
    localparam logic [6:0] OPCODE_SYSTEM    = 'b1110011;
    localparam logic [6:0] OPCODE_CUSTOM_3  = 'b1111011;

    typedef union packed {
        struct packed {
            logic [6:0]  opcode;
            logic [24:0] operand;
        } no_type;

        struct packed {
            logic [6:0] opcode;
            logic [4:0] rd;
            logic [2:0] funct3;
            logic [4:0] rs1;
            logic [4:0] rs2;
            logic [6:0] funct7;
        } r_type;

        struct packed {
            logic [6:0] opcode;
            logic [4:0] rd;
            logic [2:0] funct3;
            logic [4:0] rs1;
            logic       imm_0;
            logic [3:0] imm_4_1;
            logic [5:0] imm_10_5;
            logic       imm_11;
        } i_type;

        struct packed {
            logic [6:0] opcode;
            logic       imm_0;
            logic [3:0] imm_4_1;
            logic [2:0] funct3;
            logic [4:0] rs1;
            logic [4:0] rs2;
            logic [5:0] imm_10_5;
            logic       imm_11;
        } s_type;

        struct packed {
            logic [6:0] opcode;
            logic       imm_11;
            logic [3:0] imm_4_1;
            logic [2:0] funct3;
            logic [4:0] rs1;
            logic [4:0] rs2;
            logic [5:0] imm_10_5;
            logic       imm_12;
        } sb_type;

        struct packed {
            logic [6:0]  opcode;
            logic [4:0]  rd;
            logic [2:0]  imm_14_12;
            logic [4:0]  imm_19_15;
            logic [10:0] imm_30_20;
            logic        imm_31;
        } u_type;

        struct packed {
            logic [6:0] opcode;
            logic [4:0] rd;
            logic [2:0] imm_14_12;
            logic [4:0] imm_19_15;
            logic       imm_11;
            logic [3:0] imm_4_1;
            logic [5:0] imm_10_5;
            logic       imm_20;
        } uj_type;
    } ir_t;
 
endpackage : rv32i
