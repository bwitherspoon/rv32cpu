        .section .init, "ax"
        .align 5
        .globl init

init:   lui  t0,0x40000 # GPIO base address
        li   t1,-1      # GPIO 3-state control
        slli t1,t1,16
        sw   t1,4(t0)
        lui  t0,0x40001 # UART base address
        li   t1,0x13    # UART reset and enable interrupt
        sw   t1,0xC(t0)
        li   sp,0x2000  # Initialize stack pointer
        j    main
