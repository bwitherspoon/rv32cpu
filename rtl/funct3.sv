/**
 * Package: funct3
 */
package funct3;

    typedef logic [2:0] funct3_t;

    localparam funct3_t JALR  = 'b000;
    localparam funct3_t BEQ   = 'b000;
    localparam funct3_t BNE   = 'b001;
    localparam funct3_t BLT   = 'b100;
    localparam funct3_t BGE   = 'b101;
    localparam funct3_t BLTU  = 'b110;
    localparam funct3_t BGEU  = 'b111;
    localparam funct3_t LB    = 'b000;
    localparam funct3_t LH    = 'b001;
    localparam funct3_t LW    = 'b010;
    localparam funct3_t LBU   = 'b100;
    localparam funct3_t LHU   = 'b101;
    localparam funct3_t SB    = 'b000;
    localparam funct3_t SH    = 'b001;
    localparam funct3_t SW    = 'b010;
    localparam funct3_t ADDI  = 'b000;
    localparam funct3_t SLTI  = 'b010;
    localparam funct3_t SLTIU = 'b011;
    localparam funct3_t XORI  = 'b100;
    localparam funct3_t ORI   = 'b110;
    localparam funct3_t ANDI  = 'b111;
    localparam funct3_t SLLI  = 'b001;
    localparam funct3_t SLRI  = 'b101;
    localparam funct3_t SRAI  = 'b101;

endpackage


