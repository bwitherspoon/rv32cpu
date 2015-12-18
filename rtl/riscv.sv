/**
 * Package: risvc
 */
package riscv;

    /*
     * Data
     */

    // Opcodes
    typedef logic [6:0] opcode_t;

    localparam opcode_t OPCODE_LOAD      = 'b0000011;
    localparam opcode_t OPCODE_LOAD_FP   = 'b0000111;
    localparam opcode_t OPCODE_CUSTOM_0  = 'b0001011;
    localparam opcode_t OPCODE_MISC_MEM  = 'b0001111;
    localparam opcode_t OPCODE_OP_IMM    = 'b0010011;
    localparam opcode_t OPCODE_AUIPC     = 'b0010111;
    localparam opcode_t OPCODE_OP_IMM_32 = 'b0011011;
    localparam opcode_t OPCODE_STORE     = 'b0100011;
    localparam opcode_t OPCODE_STORE_FP  = 'b0100111;
    localparam opcode_t OPCODE_CUSTOM_1  = 'b0101011;
    localparam opcode_t OPCODE_AMO       = 'b0101111;
    localparam opcode_t OPCODE_OP        = 'b0110011;
    localparam opcode_t OPCODE_LUI       = 'b0110111;
    localparam opcode_t OPCODE_OP_32     = 'b0111011;
    localparam opcode_t OPCODE_MADD      = 'b1000011;
    localparam opcode_t OPCODE_MSUB      = 'b1000111;
    localparam opcode_t OPCODE_NMSUB     = 'b1001011;
    localparam opcode_t OPCODE_NMADD     = 'b1001111;
    localparam opcode_t OPCODE_OP_FP     = 'b1010011;
    localparam opcode_t OPCODE_CUSTOM_2  = 'b1011011;
    localparam opcode_t OPCODE_BRANCH    = 'b1100011;
    localparam opcode_t OPCODE_JALR      = 'b1100111;
    localparam opcode_t OPCODE_JAL       = 'b1101111;
    localparam opcode_t OPCODE_SYSTEM    = 'b1110011;
    localparam opcode_t OPCODE_CUSTOM_3  = 'b1111011;

    // Register address type
    typedef logic [4:0]  reg_t;

    // Memory address type
    typedef logic [11:0] addr_t;

    // Word type
    typedef logic [31:0] data_t;

    // Immediate type
    typedef logic signed [31:0] imm_t;

    typedef logic [6:0] funct7_t;

    typedef logic [2:0] funct3_t;

    localparam funct3_t FUNCT3_JALR    = 'b000;
    localparam funct3_t FUNCT3_BEQ     = 'b000;
    localparam funct3_t FUNCT3_BNE     = 'b001;
    localparam funct3_t FUNCT3_BLT     = 'b100;
    localparam funct3_t FUNCT3_BGE     = 'b101;
    localparam funct3_t FUNCT3_BLTU    = 'b110;
    localparam funct3_t FUNCT3_BGEU    = 'b111;
    localparam funct3_t FUNCT3_LB      = 'b000;
    localparam funct3_t FUNCT3_LH      = 'b001;
    localparam funct3_t FUNCT3_LW      = 'b010;
    localparam funct3_t FUNCT3_LBU     = 'b100;
    localparam funct3_t FUNCT3_LHU     = 'b101;
    localparam funct3_t FUNCT3_SB      = 'b000;
    localparam funct3_t FUNCT3_SH      = 'b001;
    localparam funct3_t FUNCT3_SW      = 'b010;
    localparam funct3_t FUNCT3_ADDI    = 'b000;
    localparam funct3_t FUNCT3_SLTI    = 'b010;
    localparam funct3_t FUNCT3_SLTIU   = 'b011;
    localparam funct3_t FUNCT3_XORI    = 'b100;
    localparam funct3_t FUNCT3_ORI     = 'b110;
    localparam funct3_t FUNCT3_ANDI    = 'b111;
    localparam funct3_t FUNCT3_SLLI    = 'b001;
    localparam funct3_t FUNCT3_SLRI    = 'b101;
    localparam funct3_t FUNCT3_SRAI    = 'b101;

    localparam funct3_t FUNCT3_ADD_SUB = 'b000;

    // Program counter type
    typedef logic [8:0] pc_t;

    // Initial program counter address
    localparam pc_t INIT_ADDR = '0;

    // Trap address
    localparam pc_t TRAP_ADDR = '1;

    // Instruction type
    typedef union packed {
        struct packed {
            funct7_t funct7;
            reg_t    rs2;
            reg_t    rs1;
            funct3_t funct3;
            reg_t    rd;
            opcode_t opcode;
        } r;

       struct packed {
            logic [11:0] imm_11_0;
            reg_t        rs1;
            funct3_t     funct3;
            reg_t        rd;
            opcode_t     opcode;
        } i;

        struct packed {
            logic [6:0] imm_11_5;
            reg_t       rs2;
            reg_t       rs1;
            funct3_t    funct3;
            logic [4:0] imm_4_0;
            opcode_t    opcode;
        } s;

        struct packed {
            logic       imm_12;
            logic [5:0] imm_10_5;
            reg_t       rs2;
            reg_t       rs1;
            funct3_t    funct3;
            logic [3:0] imm_4_1;
            logic       imm_11;
            opcode_t    opcode;
        } sb;

        struct packed {
            logic [19:0] imm_31_12;
            reg_t        rd;
            opcode_t     opcode;
        } u;

        struct packed {
            logic       imm_20;
            logic [9:0] imm_10_1;
            logic       imm_11;
            logic [7:0] imm_19_12;
            reg_t       rd;
            opcode_t    opcode;
        } uj;
    } ir_t;

    // NOP instruction
    localparam ir_t BUBBLE = {
        funct7_t'(0),
        reg_t'(0),
        FUNCT3_ADDI,
        reg_t'(0),
        OPCODE_OP_IMM
    };

    /*
     * Control
     */

    // ALU operation type
    typedef enum logic [3:0] {
        ALU_ADD,
        ALU_SLL,
        ALU_SLT,
        ALU_SLTU,
        ALU_XOR,
        ALU_SRL,
        ALU_OR,
        ALU_AND,
        ALU_SUB,
        ALU_SRA,
        ALU_OP2,
        ALU_XXX  = 'x
    } alu_t;

    // Program counter select
    typedef enum logic [1:0] {
        PC_PLUS4,
        PC_TARGET,
        PC_TRAP
    } pc_sel_t;

    // Operand select
    typedef enum logic {
        OP1_RS1,
        OP1_PC,
        OP1_XXX = 'x
    } op1_sel_t;

    // Operand select
    typedef enum logic [2:0] {
        OP2_RS2,
        OP2_I_IMM,
        OP2_S_IMM,
        OP2_B_IMM,
        OP2_U_IMM,
        OP2_J_IMM,
        OP2_XXX = 'x
    } op2_sel_t;

    // Data path control signals
    typedef struct {
        logic     load;
        logic     store;
        logic     write;
        logic     link;
        alu_t     alu_op;
        pc_sel_t  pc_sel;
        op1_sel_t op1_sel;
        op2_sel_t op2_sel;
    } ctrl_t;

endpackage
