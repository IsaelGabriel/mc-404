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
    jal read

# numbers = input.to_int_array()
to_int_array:
    li a0, 0 # i = 0

to_int_array_for_i:
    li t0, 4
    bge a0, t0, to_int_array_for_i_end # for i in range(0, 4)
    li a1, 0 # j = 0
    li t0, 2 # t0 = 2
    mul t0, t0, a0 # t0 *= i
    add a2, s2, t0 # a2 = numbers + i
    li t0, 5 # t0 = 5
    mul t0, a0, t0 # t0 = i * 5
    add a3, s0, t0 # a3 = input_address + (i * 5)

to_int_array_for_j:
    li t0, 4
    bge a1, t0, to_int_array_for_j_end # for j in range(0, 4)

power_10:
    li t0, 3 # t0 = 3
    li a4, 1 # n = 1
    li a5, 0 # k = 0
    sub a6, t0, a1 # a6 = 3 - j

for_power_10:
    bge a5, a6, for_power_10_end # for k in range(0, 3 - j)
    li t0, 10 # t0 = 10
    mul a4, a4, t0 # t4 *= 10
    addi a5, a5, 1 # k++
    j for_power_10

for_power_10_end:
    add t0, a3, a1 # t0 = input_address + (i * 5) + j
    lb a5, 0(t0) # a5 = input_address[(i * 5) + j]
    addi a5, a5, -'0' # a5 = input_address[(i * 5) + j] - '0'
    mul a4, a4, a5 # a4 = (input_address[(i * 5) + j] - '0') * (10 ^ (3 - j))
    lhu t0, 0(a2) # t0 = numbers[i]
    add a4, a4, t0 # a4 = numbers[i] + a4
    sh a4, 0(a2) # numbers[i] = a4
    addi a1, a1, 1 # j++
    j to_int_array_for_j

to_int_array_for_j_end:
    addi a0, a0, 1  # i++
    j to_int_array_for_i

to_int_array_for_i_end:


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