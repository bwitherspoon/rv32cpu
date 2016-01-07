        .text
        .align 5
        .globl main

main:   lui  t0,0x40000
        lw   t1,0(t0)
        srli t1,t1,16
        andi t1,t1,0x7F
        sw   t1,0(t0)
        j    main
