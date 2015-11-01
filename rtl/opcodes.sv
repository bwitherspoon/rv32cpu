/**
 * Package: opcodes
 *
 * RISV-V opcodes
 */
package opcodes;

    typedef logic [7:0] opcode_t;

    localparam opcode_t LOAD      = 'b0000011;
    localparam opcode_t LOAD_FP   = 'b0000111;
    localparam opcode_t CUSTOM_0  = 'b0001011;
    localparam opcode_t MISC_MEM  = 'b0001111;
    localparam opcode_t OP_IMM    = 'b0010011;
    localparam opcode_t AUIPC     = 'b0010111;
    localparam opcode_t OP_IMM_32 = 'b0011011;
    localparam opcode_t STORE     = 'b0100011;
    localparam opcode_t STORE_FP  = 'b0100111;
    localparam opcode_t CUSTOM_1  = 'b0101011;
    localparam opcode_t AMO       = 'b0101111;
    localparam opcode_t OP        = 'b0110011;
    localparam opcode_t LUI       = 'b0110111;
    localparam opcode_t OP_32     = 'b0111011;
    localparam opcode_t MADD      = 'b1000011;
    localparam opcode_t MSUB      = 'b1000111;
    localparam opcode_t NMSUB     = 'b1001011;
    localparam opcode_t NMADD     = 'b1001111;
    localparam opcode_t OP_FP     = 'b1010011;
    localparam opcode_t CUSTOM_2  = 'b1011011;
    localparam opcode_t BRANCH    = 'b1100011;
    localparam opcode_t JALR      = 'b1100111;
    localparam opcode_t JAL       = 'b1101111;
    localparam opcode_t SYSTEM    = 'b1110011;
    localparam opcode_t CUSTOM_3  = 'b1111011;

endpackage


