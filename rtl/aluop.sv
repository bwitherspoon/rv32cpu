/**
 * Package: aluop
 */
package aluop;

    // ALU operation type
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
    } aluop_t;

endpackage


