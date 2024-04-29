.globl _start

_start:
    j main

end:
    li a0, 0
    li a7, 93 # exit
    ecall


main:
    jal read_first_line

convert_first_line:
    la s0, input_address # s0 = input_address
    la s1, initial_coordinates # s1 = initial_coordinates
    li a0, 0 # i = 0

for_i_convert:
    li t0, 2
    bge a0, t0, end_convert # for i in range(0, 2)
    mv s2, a0 # s2 = i
    mv a0, s0 # a0 = s0
    addi a0, a0, 1 # a0 += 1
    jal convert_integer # a0 = convert_integer(s0 + 1)
    mv a1, a0 # a1 = convert_integer(s0 + 1)
    mv a0, s2 # a0 = i
    lb t0, (s0) # t0 = input_address[i * 6]
    li t1, '+' # t1 = '+'
    beq t0, t1, for_i_convert_not_negative # if (input_address[i * 6] != '+')
    xori a1, a1, -1 # a1 = ~a1
    addi a1, a1, 1 # a1 += 1

for_i_convert_not_negative:
    sh a1, (s1) # initial_coordinates[i] = a1
    addi s0, s0, 6 # s0 += 6 
    addi s1, s1, 2 # s1 += 2
    addi a0, a0, 1 # i++
    j for_i_convert # loop

end_convert:
    jal read_second_line

convert_second_line:
    la t0, input_address # t0 = input_address
    addi s0, t0, 12 # s0 = input_address + 12
    la s1, timestamps # s1 = timestamps
    li a0, 0 # i = 0

for_i_convert_2:
    li t0, 4 # t0 = 4
    bge a0, t0, end_convert_2 # for i in range(0, 4)
    mv s2, a0 # s2 = i
    mv a0, s0 # a0 = s0
    jal convert_integer # a0 = convert_integer(s0)
    mv a1, a0 # a1 = convert_integer(s0)
    mv a0, s2 # a0 = i
    sh a1, (s1) # timestamps[i] = convert_integer(s0)
    addi s0, s0, 5 # s0 += 5
    addi s1, s1, 2 # s1 += 2
    addi a0, a0, 1 # i++
    j for_i_convert_2 # loop
    

end_convert_2:
    jal to_string
    jal write
    j end

# int convert_integer(a0:(char* start)) -> a0
convert_integer:
    li a1, 0 # n = 0
    li a2, 3 # i = 3

for_i_integer:
    bltz a2, end_convert_integer # for i in range(3, -1, -1)
    li a3, 0 # j = 0
    li a4, 1 # m = 1

for_j_integer:
    bge a3, a2, end_j_integer # for j in range(0, i)
    li t0, 10 # t0 = 10
    mul a4, a4, t0 # m *= 10
    addi a3, a3, 1 # j++
    j for_j_integer # loop

end_j_integer:
    lb t0, (a0) # t0 = *(start + i)
    addi t0, t0, -'0' # t0 = *(start + i) - '0'
    mul a4, t0, a4 # a4 = *(start + i) * (10 ^ i)
    add a1, a1, a4 # n += a4
    addi a0, a0, 1 # start += 1
    addi a2, a2, -1 # i--
    j for_i_integer # loop

end_convert_integer:
    mv a0, a1 # a0 = n
    ret # return n


# void to_string()
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

timestamps: .skip 0x08 # unsigned short timestamps[4]