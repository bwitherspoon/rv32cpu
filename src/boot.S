        .text
        .align  5
        .globl _start

_start: lui  t0,0x40000
        li   t1,-1
        slli t1,t1,16
        sw   t1,4(t0)
        j    main
