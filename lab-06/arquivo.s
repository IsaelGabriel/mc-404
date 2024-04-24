.globl _start

_start:
    jal main
    li a0, 0
    li a7, 93 # exit
    ecall


main:
    # Código aqui

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