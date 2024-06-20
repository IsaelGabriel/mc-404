.globl _start

.text
_start:
    addi sp, sp, -16
    sw ra, 12(sp)
    jal ra, main
    lw ra, 12(sp)
    addi sp, sp, 16
    li a0, 0
    li a7, 93 # exit
    ecall


main:
    addi sp, sp, -16
    sw ra, 12(sp) # store ra
    la a0, output
    li t0, 0
    sw t0, 0(a0)


    jal ra, read_decimal # int n = read_decimal()
    jal ra, compare_nodes # int i = compare_nodes(n)
    jal ra, to_string # to_string(i)
    jal ra, write # write()

    lw ra, 12(sp) # load ra
    addi sp, sp, 16
    ret 

read_decimal: # int read_decimal() -> reads input as decimal d in -10000 <= d <= 10000, returns d
    addi sp, sp, -16
    sw ra, 12(sp)                   # store ra
    sw s0, 8(sp)                    # store s0
    jal ra, read                    # read()
    li a0, 0                        # int n = 0
    li s0, 1                        # int signal = 1
    la a1, input_address            # char* a1 = *input
    lb a2, 0(a1)                    # char a2 = input[0]
    li t0, '0'                      # char t0 = '0'
    bge a2, t0, read_decimal_loop   # if input[0] >= '0' -> negative, '-' < '0'
    li s0, -1                       # signal = -1
    addi a1, a1, 1                  # read next byte
    lb a2, 0(a1)                    # a2 = input[1]

        read_decimal_loop:
            li t0, '0'                      # char t0 = '0'
            blt a2, t0, read_decimal_end    # if a2 < '0' -> string has ended
            li t1, 10                       # int t1 = 10
            mul a0, a0, t1                  # n *= 10
            sub a2, a2, t0                  # input[i] -> int(input[i])
            add a0, a0, a2                  # n += int(input[i])
            addi a1, a1, 1                  # read next byte
            lb a2, 0(a1)                    # a2 = input[i]
            j read_decimal_loop             # loop

    read_decimal_end:
        mul a0, a0, s0  # n *= signal
        lw ra, 12(sp)   # load ra
        lw s0, 8(sp)    # load s0
        addi sp, sp, 16
        ret # return n


compare_nodes: # int compare_nodes(int n) -> retuns index of LinkedList node that contains values that sum up to n
    li a1, 0  # int i = 0
    la a2, head_node # Node* node = head_node

        compare_nodes_loop:
            lw t0, 0(a2) # int sum = node->val1
            lw t1, 4(a2) # t1 = node->val2
            add t0, t0, t1 # sum = node->val1 + node->val2
            lw t1, 8(a2) # t1 = node->val3
            add t0, t0, t1 # sum = node->val1 + node->val2 + node->val3
            beq t0, a0, compare_nodes_value_found # if(sum == n) -> value found
            lw a3, 12(a2) # Node* next_node = node->next
            beq a3, zero, compare_nodes_value_not_found # end if next_node == null
            mv a2, a3 # node = next_node
            addi a1, a1, 1 # i++
            j compare_nodes_loop

    compare_nodes_value_found:
        mv a0, a1 # a0 = i
        ret # return i

    compare_nodes_value_not_found:
        li a0, -1 # a0 = -1
        ret # return -1

to_string: # void to_string(int n) -> set output to string of length 2
    la a1, output                       # char* str = *output
    blt a0, zero, to_string_minus_one   # if(n < 0) -> to_string_minus_one;
    li t0, 10                           # t0 = 10
    rem t1, a0, t0                      # t1 = n % 10
    sub a0, a0, t1                      # n -= n % 10
    div a0, a0, t0                      # n /= 10
    addi t1, t1, '0'                    # t0 = char(n % 10)
    sb t1, 2(a1)                        # output[2] = char(n % 10)
    addi a1, a1, 1                      # str = *output + 1
    li a2, 1                            # int i = 1
    
    to_string_loop:
        beq a0, zero, to_string_loop_end    # if(n == 0) end loop
        blt a2, zero, to_string_loop_end    # if(i < 0) end loop
        li t0, 10                           # t0 = 10
        rem t1, a0, t0                      # t1 = n % 10
        sub a0, a0, t1                      # n -= n % 10
        div a0, a0, t0                      # n /= 10
        addi t1, t1, '0'                    # t0 = char(n % 10)
        sb t1, 0(a1)                        # output[i] = char(n % 10)
        addi a1, a1, -1                     # str--
        addi a2, a2, -1                     # i--
        j to_string_loop                    # loop

    to_string_loop_end:
        ret

    to_string_minus_one:
    li t0, '-'              # t0 = '-'
    sb t0, 0(a1)            # str[0] = '-'
    li t0, '1'              # t0 = '1'
    sb t0, 1(a1)            # str[1] = '1'
    ret

read:
    li a0, 0             # file descriptor = 0 (stdin)
    la a1, input_address # buffer
    li a2, 7             # size - Reads 7 bytes.
    li a7, 63            # syscall read (63)
    ecall
    ret

write:
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, output       # buffer
    li t0, '\n'
    sb t0, 3(a1)        # append '\n' to end of string
    li a2, 0x04         # size - Writes 4 bytes.
    li a7, 64           # syscall write (64)
    ecall
    ret


.bss

input_address: .skip 0x07
output: .skip 0x04