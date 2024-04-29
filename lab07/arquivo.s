.globl _start

_start:
    j main

end:
    li a0, 0
    li a7, 93 # exit
    ecall


main:
    jal read_first_line
    jal convert_first_line
    jal to_string
    jal write
    j end

convert_first_line:
    la s0, input_address # s0 = input_address
    la s1, coordinates # s1 = initial_coordinates
    li a0, 0 # i = 0

for_i_convert:
    li t0, 2 # t0 = 2
    bge a0, t0, end_convert # for i in range(0, 2)
    li t0, 6 # t0 = 6
    mul t0, a0, t0 # t0 = i * 6
    add a1, s0, t0 # a1 = input_address + (i * 6)
    li a2, 0 # n = 0
    li a3, 0 # j = 0

for_j_convert:
    li t0, 4 # t0 = 4
    bge a3, t0, end_for_j_convert # for j in range(0, 4)
    
power_10:
    li a4, 1 # m = 1
    li a5, 0 # k = 0
    li t0, 3 # t0 = 3
    sub a6, t0, a3 # a6 = 3 - j

for_power_10:
    bge a5, a6, end_power_10 # for k in range(0, 3 - j)
    li t0, 10
    mul a4, a4, t0 # m *= 10
    addi a5, a5, 1 # k++
    j for_power_10

end_power_10:
    add t1, a1, a3 # t1 = input_address + (i * 6) + j
    addi t1, t1, 1 # t1 += 1
    lb a5, (t1) # a5 = input_address[(i * 6) + j]
    addi a5, a5, -'0' # a5 -= '0'
    mul a5, a4, a5 # a5 = (input_address[(i * 6) + j] - '0') * (10 ^ (3 - j))
    add a2, a2, a5 # a2 += (input_address[(i * 6) + j] - '0') * (10 ^ (3 - j))
    addi a3, a3, 1 # j++
    j for_j_convert # loop

end_for_j_convert:
    lb t0, (a1) # t0 = input_address[i * 6]
    li t1, '+' # t1 = '+'
    beq t0, t1, end_for_j_convert_not_negative # if(input_address[i * 6] != '+')
    xori a2, a2, -1 # a2 = ~a2
    addi a2, a2, 1 # a2 += 1

end_for_j_convert_not_negative:
    li t0, 2 # t0 = 2
    mul t0, t0, a0 # t0 = i * 2
    add t0, s1, t0 # t0 = initial_coordinates + (i * 2)
    sh a2, (t0) # initial_coordinates[i]
    addi a0, a0, 1 # i++
    j for_i_convert # loop

end_convert:
    ret

to_string:
    la s0, coordinates # s0 = coordinates
    la s1, result # s1 = result
    li a0, 0 # i = 0

for_i_to_string:
    li t0, 2 # t0 = 2
    bge a0, t0, end_to_string # for i in range(0,2)
    li t0, 6 # t0 = 6
    mul t0, a0, t0 # t0 = i * 6
    add a1, s1, t0 # a1 = result + (i * 6) -> string_start
    li t0, 2 # t0 = 2
    mul t0, a0, t0 # t0 = i * 2
    add a2, s0, t0 # a2 = coordinates + (i * 2) -> coord_start
    lh a3, (a2) # a3 = coordinates[i]
    srli a4, a3, 31 # a4 = a3 >> 31
    slli a4, a4, 1 # a4 *= 2
    addi a4, a4, '+' # a4 += '+' -> (Becomes either '+' or '-')
    sb a4, (a1) # result[i * 6] = a4
    addi a1, a1, 1 # a1 += 1

if_coord_negative:
    bgt a3, zero, end_if_coord_negative # if(coordinates[i] < 0)
    addi a3, a3, -1 # a3 -= 1
    xori a3, a3, -1 # a3 = !a3

end_if_coord_negative:
    li a4, 3 # j = 3

for_j_to_string:
    blt a4, zero, end_for_j_to_string # for j in range(3, -1, -1)
    li t0, 10 # t0 = 10
    remu t0, a3, t0 # t0 = coordinates[i] % 10
    sub a3, a3, t0 # a3 -= coordinates[i] % 10
    li t1, 10 # t1 = 10
    divu a3, a3, t1 # a3 = (coordinates[i] - (coordinates[i] % 10)) / 10 
    add t1, a1, a4 # t1 = result + (i * 6) + j
    addi t0, t0, '0' # t0 += '0'
    sb t0, (t1) # result[(i * 6) + j] = t0
    addi a4, a4, -1 #j --
    j for_j_to_string # loop

end_for_j_to_string:
    addi a1, a1, 4 # a1 = result + (i * 6) + 4
    li t0, ' ' # t0 = ' '
    sb t0, (a1) # result[(i * 6) + 4] = ' '
    addi a0, a0, 1 # i++
    j for_i_to_string # loop

end_to_string:
    addi a0, s1, 0xB # a0 = result + 0xB
    li t0, '\n'
    sb t0, (a0)
    ret

read_first_line:
    li a0, 0            # file descriptor = 0 (stdin)
    la a1, input_address # buffer
    li a2, 12           # size - Reads 12 bytes.
    li a7, 63           # syscall read (63)
    ecall
    ret

read_second_line:
    li a0, 0            # file descriptor = 0 (stdin)
    la a1, input_address # buffer
    addi a1, a1, 12
    li a2, 20           # size - Reads 20 bytes.
    li a7, 63           # syscall read (63)
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

input_address: .skip 0x20  # buffer -> first_line (+0) second_line (+12) 

result: .skip 0x10

coordinates: .skip 0x04 # short coordinates[2]

initial_coordinates: .skip 0x04 # short initial_coordinates[2]