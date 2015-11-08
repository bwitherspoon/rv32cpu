/**
 * Package: riscv
 */
package riscv;

    import opcodes::opcode_t;
    import funct::funct3_t;
    import funct::funct7_t;
    import aluop::aluop_t;

    // Register address type
    typedef logic [4:0]  reg_t;

    // Memory address type
    typedef logic [11:0] addr_t;

    // Word type
    localparam XLEN = 32;
    typedef logic [XLEN-1:0] data_t;

    // Immediate type
    typedef logic signed [31:0] imm_t;

    // Program counter type
    typedef logic [8:0]  pc_t;

    // Instruction type
    typedef union packed {
      struct packed {
            opcode_t    opcode;
            reg_t       rd;
            funct3_t    funct3;
            reg_t       rs1;
            reg_t       rs2;
            funct7_t    funct7;
        } r;

        struct packed {
            opcode_t     opcode;
            reg_t        rd;
            funct3_t     funct3;
            reg_t        rs1;
            logic [11:0] imm_11_0;
        } i;

        struct packed {
            opcode_t    opcode;
            logic [4:0] imm_4_0;
            funct3_t    funct3;
            reg_t       rs1;
            reg_t       rs2;
            logic [6:0] imm_11_5;
        } s;

        struct packed {
            opcode_t    opcode;
            logic       imm_11;
            logic [3:0] imm_4_1;
            funct3_t    funct3;
            reg_t       rs1;
            reg_t       rs2;
            logic [5:0] imm_10_5;
            logic       imm_12;
        } sb;

        struct packed {
            opcode_t     opcode;
            reg_t        rd;
            logic [19:0] imm_31_12;
        } u;

        struct packed {
            opcode_t    opcode;
            reg_t       rd;
            logic [7:0] imm_19_12;
            logic       imm_11;
            logic [9:0] imm_10_1;
            logic       imm_20;
        } uj;
    } ir_t;

    // NOP instruction
    localparam ir_t NOP = {
        opcodes::OP_IMM,
        reg_t'(0),
        funct::ADDI,
        reg_t'(0),
        12'h000
    };

    // Initial program counter address
    localparam pc_t INIT = 'h2000;

endpackage
