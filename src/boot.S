        .text
        .align 5
        .globl main

main:   lui  t0,0x40001   # UART read size
        lw   t1,8(t0)
        andi t1,t1,1
        beq  t1,zero,main
        lw   t2,0(t0)
        slli t2,t2,8
size:   lw   t1,8(t0)
        andi t1,t1,1
        beq  t1,zero,size
        lw   t3,0(t0)
        or   t1,t2,t3
        li   t5,0x400
        li   a0,0x1
read:   beq  t1,zero,done # UART read binary
        li   t2,4
        li   t4,0
byte:   addi t2,t2,-1
        sw   t6,0(s0)     # GPIO indicate byte read
        slli t4,t4,8
wait:   lw   t3,8(t0)
        andi t3,t3,1
        beq  t3,zero,wait
        lw   t3,0(t0)
        or   t4,t4,t3
        slli t6,t6,1
        bne  t2,zero,byte
        sw   t4,0(t5)
        addi t5,t5,4
        addi t1,t1,-1
        li   t6,1
        j    read
done:   li   t6,0
        sw   t6,0(s0)
        j    0x400
