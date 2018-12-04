/**
 * Copyright (c) 2015-2018 C. Brett Witherspoon
 */
package rv32;

    import opcodes::opcode_t;

    // Word type
    typedef logic [31:0] word_t;

    // Register address type
    typedef logic [4:0] addr_t;

    // Byte strobe type
    typedef logic [$bits(word_t)/8-1:0] strb_t;

    // Immediate type
    typedef logic signed [31:0] imm_t;

    // Reset address
    localparam RESET_ADDR = 32'h00000000;

    // Trap address
    localparam TRAP_ADDR = 32'h00000004;

    // Instruction address space base
    localparam CODE_BASE = 32'h00000400;

    // Instruction address space size
    localparam CODE_SIZE = 32'h00000C00;

    // Data address space base
    localparam DATA_BASE = 32'h00001000;

    // Data address space size
    localparam DATA_SIZE = 32'h00001000;

    // Memory mapped peripheral address space
    localparam MMIO_BASE = 32'h00400000;

    // Instruction type
    typedef union packed {
        struct packed {
            logic [6:0] funct7;
            logic [4:0] rs2;
            logic [4:0] rs1;
            logic [2:0] funct3;
            logic [4:0] rd;
            opcode_t    opcode;
        } r;
       struct packed {
            logic [11:0] imm_11_0;
            logic [4:0]  rs1;
            logic [2:0]  funct3;
            logic [4:0]  rd;
            opcode_t     opcode;
        } i;
        struct packed {
            logic [6:0] imm_11_5;
            logic [4:0] rs2;
            logic [4:0] rs1;
            logic [2:0] funct3;
            logic [4:0] imm_4_0;
            opcode_t    opcode;
        } s;
        struct packed {
            logic       imm_12;
            logic [5:0] imm_10_5;
            logic [4:0] rs2;
            logic [4:0] rs1;
            logic [2:0] funct3;
            logic [3:0] imm_4_1;
            logic       imm_11;
            opcode_t    opcode;
        } sb;
        struct packed {
            logic [19:0] imm_31_12;
            logic [4:0]  rd;
            opcode_t     opcode;
        } u;
        struct packed {
            logic       imm_20;
            logic [9:0] imm_10_1;
            logic       imm_11;
            logic [7:0] imm_19_12;
            logic [4:0] rd;
            opcode_t    opcode;
        } uj;
    } inst_t;

    localparam NOP = 32'h00000013;

    /*
     * Control
     */

    // CPU function type
    typedef enum logic [3:0] {
        NONE,
        INTEGER,
        BRANCH,
        JUMP,
        LOAD_WORD,
        LOAD_HALF,
        LOAD_BYTE,
        LOAD_HALF_UNSIGNED,
        LOAD_BYTE_UNSIGNED,
        STORE_WORD,
        STORE_HALF,
        STORE_BYTE
    } op_t;

    // ALU operation type
    typedef enum logic [3:0] {
        ADD,
        SLL,
        SLT,
        SLTU,
        XOR,
        SRL,
        OR,
        AND,
        SUB,
        SRA,
        OP2,
        ANY = 4'bxxxx
    } fn_t;

    // Jump / Branch operation type
    typedef enum logic [2:0] {
        JAL,
        JALR,
        BEQ,
        BNE,
        BLT,
        BLTU,
        BGE,
        BGEU,
        NA = 3'bxxx
    } br_t;

    // Program counter select
    typedef enum logic [1:0] {
        NEXT,
        ADDR,
        TRAP
    } pc_t;

    // First operand select
    typedef enum logic {
        RS1,
        PC,
        XX = 1'bx
    } op1_t;

    // Second operand select
    typedef enum logic [2:0] {
        RS2,
        I_IMM,
        S_IMM,
        B_IMM,
        U_IMM,
        J_IMM,
        XXX = 3'bxxx
    } op2_t;

    // Source register select (forwarding)
    typedef enum logic [1:0] {
        REG,
        ALU,
        EXE,
        MEM
    } rs_t;

    // Data path control signals
    typedef struct packed {
        op_t  op;
        fn_t  fn;
        br_t  br;
        op1_t op1;
        op2_t op2;
    } ctrl_t;

    /*
     * Pipeline structures
     */

    // Decode instruction structure
    typedef struct packed {
        struct packed {
            word_t pc;
            inst_t ir;
        } data;
    } id_t;

    // Execute instruction structure
    typedef struct packed {
        struct packed {
            op_t op;
            fn_t fn;
            br_t br;
        } ctrl;
        struct packed {
            word_t pc;
            word_t op1;
            word_t op2;
            word_t rs1;
            word_t rs2;
            addr_t rd;
        } data;
    } ex_t;

    // Memory structure
    typedef struct packed {
        struct packed {
            op_t op;
            br_t br;
        } ctrl;
        struct packed {
            word_t alu;
            word_t rs2;
            addr_t rd;
        } data;
    } mm_t;

    // Write-back structure
    typedef struct packed {
        struct packed {
            op_t op;
        } ctrl;
        struct packed {
            struct packed {
                word_t data;
                addr_t addr;
            } rd;
       } data;
    } wb_t;

    /*
     * Helper functions (synthesizable)
     */

    function logic isload(input op_t op);
        return op == LOAD_WORD || op == LOAD_HALF || op == LOAD_BYTE ||
               op == LOAD_HALF_UNSIGNED || op == LOAD_BYTE_UNSIGNED;
    endfunction

    function logic isstore(input op_t op);
        return op == STORE_WORD || op == STORE_HALF || op == STORE_BYTE;
    endfunction

    function logic isinteger(input op_t op);
        return op == INTEGER;
    endfunction

    function logic isjump(input op_t op);
        return op == JUMP;
    endfunction

    function logic isbranch(input op_t op);
        return op == BRANCH;
    endfunction

endpackage
