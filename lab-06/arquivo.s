.globl _start

_start:
    j main

end:
    li a0, 0
    li a7, 93 # exit
    ecall


main:
    li t0, 0

to_str:
    la a0, input_address # load input_address into a0
    li a1, 0             # i = 0

for_to_str:
    li t0, 4
    bge a1, t0, end_for_to_str # for(i = 0; i < size; i++)
    addi a1, a1, 1
    j for_to_str

end_for_to_str:
    jal write
    j end

read:
    li a0, 0             # file descriptor = 0 (stdin)
    la a1, input_address # buffer
    li a2, 20            # size - Reads 20 bytes.
    li a7, 63            # syscall read (63)
    ecall
    ret

write:
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, result       # buffer
    li a2, 20           # size - Writes 20 bytes.
    li a7, 64           # syscall write (64)
    ecall
    ret



.bss

input_address: .skip 0x20  # buffer

result: .skip 0x20