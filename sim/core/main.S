    .file   "main.S"
    .text
    .align  2

_start:
    nop
    lui  t0,8
    nop
    nop
    addi t0,t0,10
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
    lw   t1,512(zero)
    lh   t2,512(zero)
    lhu  t3,512(zero)
    lb   t4,512(zero)
    lbu  t5,512(zero)
    jal  x0,_start

