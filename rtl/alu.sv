/**
 * Pacakge: alu
 */
package alu;

    import riscv::WORD_WIDTH;

    localparam SHAMT_WIDTH = 5;
    localparam FUNCT_WIDTH = 4;
    
    typedef enum logic [FUNCT_WIDTH-1:0] {
        ADD  = 'b0000,
        SUB  = 'b1000,
        SLL  = 'b0001,
        SLT  = 'b0010,
        SLTU = 'b0011,
        XOR  = 'b0100,
        SRL  = 'b0101,
        SRA  = 'b1101,
        OR   = 'b0110,
        AND  = 'b0111
    } funct_t;
    
    /**
     * Module: alu
     * 
     * An ALU
     */
    module alu (
        input  funct_t                   funct,
        input  logic   [SHAMT_WIDTH-1:0] shamt,
        input  logic   [WORD_WIDTH-1:0]  operand1,
        input  logic   [WORD_WIDTH-1:0]  operand2,
        output logic   [WORD_WIDTH-1:0]  result
    );
    
        always @*
            case (funct)
                ADD:  result = operand1 + operand2;
                SUB:  result = operand1 - operand2;
                SLL:  result = operand1 << operand2;
                SLT:  result = signed`(operand1) < signed`(operand2);
                SLTU: result = operand1 < operand2;
                XOR:  result = operand1 ^ operand2;
                SRL:  result = operand1 >> operand2;
                SRA:  result = signed`(operand1) >>> operand2;
                OR:   result = operand1 | operand2;
                AND:  result = operand1 & operand2;
                default: result = {WORD_WIDTH{1'bx}};
            endcase
        
    endmodule

endpackage