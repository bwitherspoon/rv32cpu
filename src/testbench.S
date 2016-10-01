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
    # Test execute and memory forwarding
    li  t0,-1
    li  t1, 6
    add t2,t0,t1
    # Test memory and writeback forwarding
    li  t0, 4
    li  t1, 5
    nop
    add t2,t0,t1
    j   .
