/**
 * Package: aluop
 */
package aluop;

    // ALU operation type
    typedef enum logic [3:0] {
        ADD,
        SLL,
        SLT,
        SLTU,
        XOR,
        SRL,
        OR ,
        AND,
        SUB,
        SRA,
        OP2,
        XXX  = 'x
    } aluop_t;

endpackage


