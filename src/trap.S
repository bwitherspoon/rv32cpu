        .section .ktext, "ax"
        .align  2

trap:   lui  t0,1
        li   t1,0x8
        li   t3,4
l0:     addi t3,t3,-1
        lui  t4,0x200
l1:     addi t4,t4,-1
        bne  t4,zero,l1
        slli t1,t1,3
        sw   t1,0(t0)
        bne  t3,zero,l0
        j trap
