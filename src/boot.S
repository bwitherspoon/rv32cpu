        .text
        .align 5
        .globl _start

_start: la   s0,__gpio_start  # GPIO base address
        li   t0,-1            # GPIO 3-state control
        slli t0,t0,16
        sw   t0,4(s0)
        la   s1,__uart_start  # UART base address
        li   t0,0x13          # UART reset and enable interrupt
        sw   t0,0xC(s1)
        la   sp,__stack_start # Initialize stack pointer

size0:  lw   t0,8(s1)         # Loop until read first byte of program size
        andi t0,t0,1
        beq  t0,zero,size0
        lw   t0,0(s1)
        slli t0,t0,8

size1:  lw   t1,8(s1)         # Loop until read second byte of program size
        andi t1,t1,1
        beq  t1,zero,size1
        lw   t1,0(s1)
        or   t1,t0,t1

        li   t0,1
        sw   t0,0(s0)         # Turn on reading indicator LED
        la   s2,__kern_start    # Read binary program from UART
read:   beq  t1,zero,done
        li   t2,4
        li   t3,0
word:   addi t2,t2,-1
byte:   lw   t4,8(s1)         # Loop and read byte when available
        andi t4,t4,1
        beq  t4,zero,byte
        lw   t4,0(s1)
        slli t3,t3,8          # Append byte to word
        or   t3,t3,t4
        bne  t2,zero,word     # Read until four bytes are recieved
        sw   t3,0(s2)         # Store word in text section
        addi s2,s2,4          # Increment counters
        addi t1,t1,-1
        j    read
done:   sw   zero,0(s0)
        j    __kern_start

      .section .isr, "ax"
      .align 5

trap: la   t0,__gpio_start
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

