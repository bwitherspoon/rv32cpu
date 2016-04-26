        .data
        .align 5
intro:  .string "Welcome\r\n"
        .align 5
prompt: .string "> \r\n"
        .align 5
array:  .skip 256

        .text
        .align 5
        .globl main

        .equ uart, 0x40001
        .equ cr,   0x0d
        .equ nl,   0x0a

main:   la  a0,intro
        jal puts
loop:   la  a0,prompt
        jal puts
        la  a0,array
        li  a1,256
        jal gets
        j   .

getc:   lui  t0,uart
        lb   t1,8(t0)
        andi t1,t1,1
        beqz t1,getc
        lb   a0,0(t0)
        ret

gets:   lui  t0,uart
        mv   t1,a0
        li   t2,cr
        li   t3,nl
read:   bge  zero,a1,done
        mv   s0,t0
        mv   s1,t1
        mv   s2,t2
        mv   s3,ra
        jal  getc
        jal  putc
        mv   t0,s0
        mv   t1,s1
        mv   t2,s2
        mv   ra,s3
        sb   a0,0(t1)
        beqz a0,gots
        addi a1,a1,-1
        addi t1,t1,1
        beq  a0,t2,gots
        beq  a0,t3,gots
        j    read
gots:   sb   zero,0(t1)
done:   ret

putc:   lui  t0,uart
        sb   a0,4(t0)
        ret

puts:   mv   s0,a0
write:  lbu  a0,0(s0)
        beqz a0,wrote
        jal  putc
        addi s0,s0,1
        j    write
wrote:  ret

        .end
