/**
 * Package: riscv
 */
package riscv;

    import opcode::opcode_t;
    import funct3::funct3_t;
    import funct7::funct7_t;

    // Register address type
    typedef logic [4:0]  addr_t;

    // Word type
    typedef union packed {
        logic [ 3:0][ 7:0] octet;
        logic [ 1:0][15:0] halfword;
    } word_t;

    // Immediate type
    typedef logic signed [31:0] imm_t;

    // Program counter type
    typedef logic [8:0]  pc_t;

    // ALU function type
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

    // ALU shift amount type
    typedef logic [4:0] shamt_t;

    // PC target type
    typedef enum logic [1:0] {
        JALR_TGT     = 'b00,
        JAL_BXX_TGT  = 'b01,
        PC_PLUS4_TGT = 'b10
    } tgt_t;

    // Instruction type
    typedef union packed {
      struct packed {
            opcode_t    opcode;
            addr_t      rd;
            funct3_t    funct3;
            addr_t      rs1;
            addr_t      rs2;
            funct7_t    funct7;
        } r_type;

        struct packed {
            opcode_t    opcode;
            addr_t      rd;
            funct3_t    funct3;
            addr_t      rs1;
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
            addr_t      rs1;
            addr_t      rs2;
            logic [5:0] imm_10_5;
            logic       imm_11;
        } s_type;

        struct packed {
            opcode_t    opcode;
            logic       imm_11;
            logic [3:0] imm_4_1;
            funct3_t    funct3;
            addr_t      rs1;
            addr_t      rs2;
            logic [5:0] imm_10_5;
            logic       imm_12;
        } sb_type;

        struct packed {
            opcode_t     opcode;
            addr_t       rd;
            logic [2:0]  imm_14_12;
            logic [4:0]  imm_19_15;
            logic [10:0] imm_30_20;
            logic        imm_31;
        } u_type;

        struct packed {
            opcode_t    opcode;
            addr_t      rd;
            logic [2:0] imm_14_12;
            logic [4:0] imm_19_15;
            logic       imm_11;
            logic [3:0] imm_4_1;
            logic [5:0] imm_10_5;
            logic       imm_20;
        } uj_type;
    } ir_t;

    // NOP instruction
    localparam ir_t NOP = {
        opcode::OP_IMM,
        addr_t'(0),
        funct3::ADDI,
        addr_t'(0),
        12'h000
    };

    // Boot address
    localparam pc_t BOOT_ADDR = 'h2000;

endpackage
