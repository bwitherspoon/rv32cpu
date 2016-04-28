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
digits: .string "9"
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

        .equ gpio, 0x40000
        .equ uart, 0x40001
        .equ cr,   0x0d
        .equ nl,   0x0a

_start: la  a0,intro
        jal puts
loop:   la  a0,0x30
        jal putc
        la  a0,prompt
        jal puts
        la  a0,0x31
        jal putc
        la  a0,buffer
        li  a1,16
        jal gets
        la  a0,0x32
        jal putc
        #la  a0,buffer
        #jal atoi
        #bne zero,a1,fail
        #mv  s0,a2
        #jal atoi
        #bne zero,a1,fail
        j   loop
#fail:   la  a0,error
#        jal puts
#        j   loop

getc:   lui  t0,uart
        lb   t1,8(t0)
        andi t1,t1,1
        beqz t1,getc
        lb   a0,0(t0)
        ret

putc:   lui  t0,uart
        sb   a0,4(t0)
        ret

gets:   #addi sp,sp,-16
        #sw   s0,0(sp)
        #sw   s1,4(sp)
        #sw   s2,8(sp)
        #sw   s3,12(sp)
        lui  t0,uart
        mv   t1,a0
        li   t2,cr
        li   t3,nl
read:   bge  zero,a1,done
        mv   s0,t0
        mv   s1,t1
        mv   s3,ra
        jal  getc
        mv   t0,s0
        mv   t1,s1
        mv   ra,s3
        beqz a0,gots
        mv   s0,t0
        jal  putc
        mv   t0,s0
        sb   a0,0(t1)
        addi a1,a1,-1
        addi t1,t1,1
        beq  a0,t2,gots
        beq  a0,t3,gots
        j    read
gots:   sb   zero,0(t1)
        #lw   s0,4(sp)
        #lw   s1,8(sp)
        #lw   s2,12(sp)
        #lw   s3,16(sp)
        #addi sp,sp,16
done:   ret

puts:   #addi sp,sp,-16
        #sw   s0,0(sp)
        #sw   s1,4(sp)
        #sw   s2,8(sp)
        mv   s0,a0
write:  lbu  a0,0(s0)
        beqz a0,wrote
        mv   s1,ra
        jal  putc
        mv   ra,s1
        addi s0,s0,1
        j    write
wrote:  #lw   s0,0(sp)
        #lw   s1,4(sp)
        #lw   s2,8(sp)
        #addi s0,s0,16
        ret

atoi:   li   a1,1
scan:   lbu  a2,0(a0)
        beqz a2,end
        addi a0,a0,1
        andi a2,a2,0xF0
        li   t0,0x30
        bne  t0,a2,scan
        li   a1,0
        addi a2,a2,-48
end:    ret
