    .section .isr, "ax"
    .align 5

trap:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j trap

    .section .boot, "ax"
    .align 5
    .globl _start

_start:
    li  t0, 4
    li  t1, 5
    nop
    add t2,t0,t1
    j   _start
