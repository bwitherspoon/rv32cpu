    .text
    .align 5
    .globl _start

_start:
    li  t0, 4
    li  t1, 5
    nop
    nop
    add t3,t0,1
    j   _start
