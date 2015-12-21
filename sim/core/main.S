    .file   "main.S"
    .text
    .align  2

_start:
    lui  t0,1
    nop
    nop
    nop
    nop
    nop
    addi t0,t0,1
    nop
    nop
    nop
    nop
    nop
    sw   t0,512(zero)
    sh   t0,514(zero)
    sb   t0,515(zero)
    nop
    nop
    nop
    nop
    nop
    jal  x0,_start

