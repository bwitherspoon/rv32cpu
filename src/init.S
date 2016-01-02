        .text
        .align  2

_start: lui  t0,1
        lw   t1,0(t0)
        srli t1,t1,16
        andi t1,t1,0x7F
        sw   t1,0(t0)
        j _start
