    .section .vector, "ax"
    .align 5

    j    reset
    j    trap

    .section .loader, "ax"
    .align 5
    .global _start

reset:
    j _start

trap:
    j .

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

    # Test store and load
    la   t0,_fdata
    li   t1,1
    sw   t1,0(t0)
    lw   t2,0(t0)
    andi t3,t2,2

    j   .
