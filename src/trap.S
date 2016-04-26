        .section .kern, "ax"
        .align 5

trap: lui  t0,0x40000
      li   t1,0x8
      li   t3,4
loop: addi t3,t3,-1
      lui  t4,0x200
spin: addi t4,t4,-1
      bne  t4,zero,spin
      slli t1,t1,3
      sw   t1,0(t0)
      bne  t3,zero,loop
      j    trap
