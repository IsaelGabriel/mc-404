.globl _start

_start:
    j main

end:
    li a0, 0
    li a7, 93 # exit
    ecall


main:
    la s0, input_address
    la s1, result
    la s2, numbers

# numbers.to_string()
to_string:
    li a0, 0 # i = 0

to_string_for_i_less_than_4:
    li t0, 4
    bge a0, t0, to_string_for_i_less_than_4_end # for i in range(0, 4)
    li a1, 3 # j = 3
    li t0, 2 # t0 = 2
    mul t0, t0, a0 # t0 *= i
    add a2, s2, t0 # a2 = numbers + i
    lh a2, 0(a2) # a2 = numbers[i]
    li t0, 5 # t0 = 5
    mul t0, t0, a0 # t0 *= i
    add a3, s1, t0 # a3 = result + (i * 5)

to_string_for_j_greater_than_0:
    blt a1, zero, to_string_for_j_greater_than_0_end # for i in range(3, -1, -1)
    li t0, 10 # t0 = 10
    remu t1, a2, t0 # t1 = numbers[i] % 10
    sub a2, a2, t1 # numbers[i] -= numbers[i] % 10
    divu a2, a2, t0 # numbers[i] /= 10
    addi t1, t1, '0' # t1 += '0'
    add t2, a3, a1 # t2 = result + (i * 5) + j
    sb t1, 0(t2) # result[(i * 5) + j] = numbers[i] % 10 + '0'
    addi a1, a1, -1 # j--
    j to_string_for_j_greater_than_0

to_string_for_j_greater_than_0_end:
    addi t0, a3, 4 # t0 = result + (i * 5) + 4
    li t1, ' ' # t1 = ' '
    sb t1, 0(t0) # result[(i * 5) + 4] = ' '
    addi a0, a0, 1 # i++
    j to_string_for_i_less_than_4

to_string_for_i_less_than_4_end:
    jal write
    j end

read:
    li a0, 0            # file descriptor = 0 (stdin)
    la a1, input_address # buffer
    li a2, 20           # size - Reads 20 bytes.
    li a7, 63           # syscall read (63)
    ecall
    ret

write:
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, result       # buffer
    li t0, '\n'
    sb t0, 19(a1)
    li a2, 20           # size - Writes 20 bytes.
    li a7, 64           # syscall write (64)
    ecall
    ret


.bss

input_address: .skip 0x20  # buffer

result: .skip 0x20

numbers: .skip 0x8 # short numbers[4]