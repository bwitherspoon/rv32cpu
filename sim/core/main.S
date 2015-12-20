    .text;
    .globl _start;

_start:
    lui   x2, 9
    addi  x3, x0, 2
    auipc x4, 7
    jal   x1, _start
    nop
    nop
