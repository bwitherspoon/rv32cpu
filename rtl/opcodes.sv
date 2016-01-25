/**
 * Copyright (c) 2016, C. Brett Witherspoon
 */
package opcodes;

    typedef enum logic [6:0] {
        LOAD      = 'b0000011,
        LOAD_FP   = 'b0000111,
        CUSTOM_0  = 'b0001011,
        MISC_MEM  = 'b0001111,
        OP_IMM    = 'b0010011,
        AUIPC     = 'b0010111,
        OP_IMM_32 = 'b0011011,
        STORE     = 'b0100011,
        STORE_FP  = 'b0100111,
        CUSTOM_1  = 'b0101011,
        AMO       = 'b0101111,
        OP        = 'b0110011,
        LUI       = 'b0110111,
        OP_32     = 'b0111011,
        MADD      = 'b1000011,
        MSUB      = 'b1000111,
        NMSUB     = 'b1001011,
        NMADD     = 'b1001111,
        OP_FP     = 'b1010011,
        CUSTOM_2  = 'b1011011,
        BRANCH    = 'b1100011,
        JALR      = 'b1100111,
        JAL       = 'b1101111,
        SYSTEM    = 'b1110011,
        CUSTOM_3  = 'b1111011
    } opcode_t;

endpackage
