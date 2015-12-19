RV32I
=====

Some notes on the RV32I ISA.

## Register-Immediate

### I-type

 Instruction        | Operation |
:-------------------|:----------|
 addi  rd,rs1,imm12 | rd = rs1 + i_imm
 slti  rd,rs1,imm12 | rd = signed(rs1) < signed(i_imm)
 sltiu rd,rs1,imm12 | rd = rs1 < i_imm
 andi  rd,rs1,imm12 | rd = rs1 & i_imm
 ori   rd,rs1,imm12 | rd = rs1 | i_imm
 xori  rd,rs1,imm12 | rd = rs1 ^ i_imm
 slli  rd,rs1,imm12 | rd = rs1 << i_imm[4:0]
 srli  rd,rs1,imm12 | rd = rs1 >> i_imm[4:0]
 srai  rd,rs1,imm12 | rd = rs1 >>> i_imm[4:0]

### U-type

 Instruction        | Operation |
:-------------------|:----------|
 lui   rd,imm20     | rd = u_imm
 auipc rd,imm20     | rd = pc + u_imm

## Register-Register

### R-type

add  rd = rs1 + rs2
slt  rd = signed(rs1) < signed(rs2)
sltu rd = rs1 < rs2i
and  rd = rs1 & rs2
or   rd = rs1 | rs2
xor  rd = rs1 ^ rs2
sll  rd = rs1 << rs2[4:0]
srl  rd = rs1 >> rs2[4:0]
sub  rd = rs1 - rs2
sra  rd = rs1 >>> rs2[4:0]

## Branch-Jump

## UJ-type

jal rd,offset => rd = pc + 4 ; pc = pc + j_imm

## I-Type

jalr rd,rs1,offset => rd = pc + 4 ; pc = {rs1 + i_imm, 1'b0}

## SB-Type

beq  pc = (rs1 == rs2) ? pc + b_imm : pc + 4
bne  pc = (rs1 != rs2) ? pc + b_imm : pc + 4
blt  pc = (rs1 < rs2)  ? pc + b_imm : pc + 4
bltu pc = (rs1 < rs2)  ? pc + b_imm : pc + 4
bge  pc = (rs1 >= rs2) ? pc + b_imm : pc + 4
bgeu pc = (rs1 >= rs2) ? pc + b_imm : pc + 4

## Load-Store

### I-Type

lw  rd,rs1,offset rd = M[rs1 + offset]
lh  rd,rs1,offset rd = M[rs1 + offset][15:0] >>> 16
lhu rd,rs1,offset rd = M[rs1 + offset][15:0] >> 16
lb  rd,rs1,offset rd = M[rs1 + offset][7:0] >>> 24
lbu rd,rs1,offset rd = M[rs1 + offset][7:0] >> 16

### S-Type

sw rs1,rs2,offset M[rs1 + offset] = rs2
sh rs1,rs2,offset M[rs1 + offset] = rs2[15:0]
sb rs1,rs2,offset M[rs1 + offset] = rs2[7:0]
