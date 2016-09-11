#
# C. Brett Witherspoon
#

        .data
intro:  .string "\r\nWelcome\n"
prompt: .string "\r\n> "
error:  .string "\r\nError"
buffer: .skip 16
#        .string "-9"
#        .string "-8"
#        .string "-7"
#        .string "-6"
#        .string "-5"
#        .string "-4"
#        .string "-3"
#        .string "-2"
#        .string "-1"
#digits: .string "0"
#        .string "1"
#        .string "2"
#        .string "3"
#        .string "4"
#        .string "5"
#        .string "6"
#        .string "7"
#        .string "8"
#        .string "9"
#        .string "10"
#        .string "11"
#        .string "12"
#        .string "13"
#        .string "14"
#        .string "15"
#        .string "16"
#        .string "17"
#        .string "18"

        .text
        .align 5
        .globl _start

        .equ gpio, 0x00400
        .equ uart, 0x00401
        .equ cr,   0x0d
        .equ nl,   0x0a

_start: la   s0,__gpio_start  # GPIO base address
        li   t1,-1            # GPIO 3-state control
        slli t1,t1,16
        sw   t1,4(s0)
        la   t0,__uart_start  # UART base address
        li   t1,0x13          # UART reset and enable interrupt
        sw   t1,0xC(t0)
        la   sp,__stack_start # Initialize stack pointer
        la   a0,intro         # Print message
        jal  puts
loop:   la   a0,prompt        # Print prompt
        jal  puts
        la   a0,buffer        # Read input
        li   a1,16
        jal  gets
        la   a0,buffer        # Attempt to convert first digit
        jal  atoi
        bnez a1,fail
        mv   s0,a2
        jal  atoi             # Attempt to convert second digit
        bnez a1,fail
        mv   s1,a2
        jal  atoi             # Fail if we find any more digits
        beqz a1,fail
        add  s2,s0,s1         # Add the first and second integers
        addi s2,s2,0x30       # Convert to ASCII digit
        li  a0,cr             # Print the result
        jal putc
        li  a0,nl
        jal putc
        mv  a0,s2
        jal putc
        j   loop
fail:   la  a0,error          # Print error message on failure
        jal puts
        j   loop

#
# Read a character from the UART into a0. Spins if no character is available.
#
getc:   lui  t0,uart
        lb   t1,8(t0)
        andi t1,t1,1
        beqz t1,getc
        lb   a0,0(t0)
        ret

#
# Write the character in a0 to the UART.
#
putc:   lui  t0,uart
        sb   a0,4(t0)
        ret
#
# Reads a line from the UART and writes it to the buffer at the address in a0.
# The limit on the number of characters to be read shall be in a1. The newline
# character or last character is replaced with the null character.
#
gets:   addi sp,sp,-12
        sw   s0,0(sp)
        sw   s1,4(sp)
        sw   ra,8(sp)
        mv   s0,a0
        mv   s1,a1
read:   bge  zero,s1,done
        jal  getc
        beqz a0,gots
        jal  putc
        sb   a0,0(s0)
        addi s0,s0,1
        addi s1,s1,-1
        li   t0,cr
        beq  a0,t0,gots
        li   t0,nl
        beq  a0,t0,gots
        j    read
gots:   sb   zero,0(s0)
done:   lw   s0,0(sp)
        lw   s1,4(sp)
        lw   ra,8(sp)
        addi sp,sp,12
        ret

#
# Writes a null terminated string at the address in a0 to the UART.
#
puts:   addi sp,sp,-8
        sw   s0,0(sp)
        sw   ra,4(sp)
        mv   s0,a0
write:  lbu  a0,0(s0)
        beqz a0,wrote
        jal  putc
        addi s0,s0,1
        j    write
wrote:  lw   s0,0(sp)
        lw   ra,4(sp)
        addi s0,s0,8
        ret
#
# Converts the first numeric ASCII character to an integer 1-9 in a null
# terminated string at the address in a0. Returns 1 in a1 on failure and 0 on
# success. Returns the integer in register a2. The address in register a0 will
# point to the character after the first integer 1-9 found.
#
atoi:   li   a1,1
scan:   lbu  a2,0(a0)
        beqz a2,end
        addi a0,a0,1
        li   t0,0x30
        bltu a2,t0,scan
        li   t0,0x3A
        bgeu a2,t0,scan
        li   a1,0
        addi a2,a2,-48
end:    ret
