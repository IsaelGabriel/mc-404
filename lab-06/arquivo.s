.data
ascii_zero: .byte 0x30

.text
.globl _start

_start:
    jal main
    li a0, 0
    li a7, 93 # exit
    ecall


main:
    jal read    # read input
    jal convert_from_str # convert input from str to int[4]
    jal sqrt # sqrt all numbers
    jal convert_to_str # convert numbers to str
    jal write
    ret

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

convert_from_str:
    la s0, numbers # int* s0 = numbers
    la s1, input_address # char* s1 = input_address
    li s2, 4 # int max = 4
    li t0, 0 # int i = 0

for_n_in_str:
    bge t0, s2, end_for_n_in_str # for(i = 0; i < 4; i++)
    li t1, 0 # int j = 0 (Last char on number)

for_c_in_n:
    bge t1, s2, end_for_c_in_n # for(j = 0; j < 4; j++)
    li a0, 0 # int numbers[i] = 0
    li a1, 10 # int a1 = 10
    sub a2, s2, t1 # int a2 = 4 - j
    addi a2, a2, -1 # a2--

power:
    li t2, 0 # int k = 0
    li t3, 1 # int t3 = 1

for_power:
    bge t2, a2, end_power # for(k = 0; k < a2; k++)
    mul t3, t3, a1 # t3 *= a1
    addi t2, t2, 1 # k++
    j for_power

end_power:
    addi a1, t3, 0 # a1 = 10^a2
    add t2, s1, t1 # t2 = &(n[j])
    lb t2, 0(t2) # t2 = *t2
    la t3, ascii_zero # t3 = &ascii_zero
    lb t3, 0(t3) # t3 = *t3
    sub t2, t2, t3 # t2 -= t3
    mul t2, t2, a1 # t2 *= a1
    add a0, a0, t2 # a0 += t2
    addi t1, t1, 1 # j++
    j for_c_in_n

end_for_c_in_n:
    sw a0, 0(s0) # numbers[i] = a0
    addi s0, s0, 4 # s0 += 4 -> next address in numbers
    addi s1, s1, 5 # s1 += 5 -> first char on next number
    addi t0, t0, 1 # i++
    j for_n_in_str

end_for_n_in_str:
    ret

sqrt: # take the sqrt from every number and store it into numbers
    la s0, numbers # int* s0 = numbers
    li s1, 4 # max_i = 4
    li s2, 10 # max_j = 10
    li t0, 0 # i = 0

for_sqrt:
    bge t0, s1, end_for_sqrt # for(i = 0; i < 4; i++)
    lw a0, 0(s0) # a0 = numbers[i]
    srli a1, a0, 1 # a1 = a0 / 2
    li t1, 0 # j = 0

for_iter:
    bge t1, s2, end_for_iter # for(j = 0; j < 10; j++)
    divu a2, a0, a1 # a2 = numbers[i] / a1
    add a1, a1, a2 # a1 += a2
    srli a1, a1, 1 # a1 /= 2
    addi t1, t1, 1 # j++
    j for_iter

end_for_iter:
    sw a1, 0(s0)  # stores a1 into numbers[i]
    addi s0, s0, 4 # s0 += 4 -> next address in numbers
    addi t0, t0, 1 # i++
    j for_sqrt

end_for_sqrt:
    ret

convert_to_str:
    la s0, numbers # s0 = numbers
    la s1, result # s1 = result
    li s2, 4 # max_i = 4
    li t0, 0 # i = 0
    la s3, ascii_zero # s3 = &ascii_zero
    lb s3, 0(s3) # s3 = *s3
    li s4, 10 # s4 = 10

for_n_in_numbers:
    bge t0, s2, end_for_n_in_numbers # for(int i = 0; i < 4; i++)
    li t1, 3 # j = 3
    lw a0, 0(s0) # a0 = numbers[i]

for_a_in_number:
    blt t1, x0, end_for_a_in_number # for(int j = 3; j >= 0; j++)
    remu a1, a0, s4 # a1 = a0 % 10
    add a2, a1, s3 # a2 = a1 + ascii_zero
    add a3, s1, t1 # a3 = result + (i * 5 + j)
    sb a2, 0(a3) # stores a2 into result[i * 5 + j]
    sub a0, a0, a1 # a0 -= a0 % 10
    divu a0, a0, s4 # a0 /= 10
    addi t1, t1, -1 # j--
    j for_a_in_number

end_for_a_in_number:
    addi t0, t0, 1 # i++
    addi s0, s0, 4 # s0 = numbers + i
    addi s1, s1, 5 # s1 += result + (i * 5)
    j for_n_in_numbers

end_for_n_in_numbers:
    ret
.bss

input_address: .skip 0x20  # buffer

result: .skip 0x20

numbers: .skip 0x80 # unsigned int numbers[4]