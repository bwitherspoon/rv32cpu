#
# C. Brett Witherspoon
#

        .data
intro:  .string "\r\nWelcome\n"
prompt: .string "\r\n> "
error:  .string "\r\nError"
buffer: .skip 16

        .text
        .align 5
        .globl _start

        .equ cr,   0x0d
        .equ nl,   0x0a

_start: la   t0,_gpio        # GPIO base address
        li   t1,-1            # GPIO 3-state control
        slli t1,t1,16
        sw   t1,4(t0)
        la   t0,_uart         # UART base address
        li   t1,0x13          # UART reset and enable interrupt
        sw   t1,0xC(t0)
        la   sp,_stack        # Initialize stack pointer
        la   a0,intro         # Print message
        jal  puts
loop:   la   a0,prompt        # Print prompt
        jal  puts
        la   a0,buffer        # Read input
        li   a1,16
        jal  gets
        la   a0,buffer        # Attempt to convert first digit to an integer
        jal  atoi
        bnez a1,fail
        mv   s0,a2
        jal  operator         # Attempt to find the operator
        beqz a1,fail
        jal  atoi             # Attempt to convert second digit to an integer
        bnez a1,fail
        mv   s1,a2
        lbu  t0,0(a0)         # Fail if this is not the end of the string
        bnez t0,fail
        add  a0,s0,s1         # Add the first and second integers
        jal  itoa             # Attempt to convert the result to a character
        bnez a1,fail
        mv   s2,a0
        li   a0,cr            # Print the result
        jal  putc
        li   a0,nl
        jal  putc
        mv   a0,s2
        jal putc
        j   loop
fail:   la  a0,error          # Print error message on failure
        jal puts
        j   loop

#
# Read a character from the UART into a0. Spins if no character is available.
#
getc:   la   t0,_uart
        lb   t1,8(t0)
        andi t1,t1,1
        beqz t1,getc
        lb   a0,0(t0)
        ret

#
# Write the character in a0 to the UART.
#
putc:   la   t0,_uart
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
        li   t0,cr
        beq  a0,t0,gots
        li   t0,nl
        beq  a0,t0,gots
        sb   a0,0(s0)
        addi s0,s0,1
        addi s1,s1,-1
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
# Converts the integer in a0 to a hexadecimal character. Returns 1 in a1 if the
# integer is not a number in [0,16] and 0 otherwise.
#
itoa: li   a1,1
      li   t0,16
      bgeu a0,t0,exit
      li   a1,0
      addi a0,a0,0x30
      li   t0,0x3A
      bltu a0,t0,exit
      addi a0,a0,7
exit: ret

#
# Converts the first hexadecimal (uppercase) ASCII character in a null
# terminated string starting at the address in a0. Returns 1 in a1 on failure
# and 0 on success.  Returns the integer in register a2. The address in register
# a0 will point to the character after the first valid character found.
#
atoi:    li   a1,1
numeral: lbu  a2,0(a0)
         beqz a2,return
         addi a0,a0,1
         li   t0,'0          # Look for a numerical character 0-9
         bltu a2,t0,numeral
         li   t0,':
         bgeu a2,t0,letter
         li   a1,0
         addi a2,a2,-0x30
         j    return
letter:  li   t0,'A       # Look for a letter character A-F
         bltu a2,t0,numeral
         li   t0,'G
         bgeu a2,t0,numeral
         li   a1,0
         addi a2,a2,-0x37
return:  ret

#
# Looks for an operator character in a null terminated string starting at the
# address in a0. Returns 0 in a1 on failure and an operation index on success.
# The address in register a0 will point to the character after the first valid
# character found.
#
operator: li   a1,0
search:   lbu  t0,0(a0)
          beqz t0,complete
          addi a0,a0,1
          li   t1,'+
          bne  t0,t1,search
          li   a1,1
complete: ret
