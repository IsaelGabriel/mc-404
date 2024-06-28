.globl recursive_tree_search
.globl puts
.globl gets
.globl atoi
.globl itoa
.globl exit

.text

recursive_tree_search: # int recursive_tree_search(Node *root_node, int val)
    ret

puts: # void puts ( const char *str )
    addi sp, sp, -16
    sw ra, 12(sp)               # store ra
    sw s0, 8(sp)                # store s0
    mv s0, a0                   # s0 = str
    puts_loop:
        lb t0, 0(s0)            # t0 = str[i]
        beq t0, zero, puts_end  # if t0 == 0 -> end
        mv a1, s0               # a1 = *(str + i)
        jal ra, write_byte      # write_byte(str[i])
        addi s0, s0, 1          # str++
        j puts_loop             # loop
    puts_end:
        li t0, '\n'             # t0 = '\n'
        sb t0, 0(s0)            # str[i] = '\n'
        mv a1, s0               # a1 = str + i
        jal ra, write_byte      # write_byte(str + i)
        lw s0, 8(sp)            # load s0
        lw ra, 12(sp)           # load ra
        addi sp, sp, 16
        ret                     # return

gets: # char *gets ( char *str )
    addi sp, sp, -16            # alloc 16
    sw ra, 12(sp)               # store ra
    sw s0, 8(sp)                # store s0
    sw a0, 4(sp)                # store str
    mv s0, a0                   # char* char_ptr = str
    gets_loop:
        mv a1, s0               # a1 = char_ptr
        jal ra, read_byte       # read_byte(char_ptr)
        lw t0, 0(s0)            # t0 = str[i]
        li t1, '\n'             # t1 = '\n'
        beq t0, t1, gets_end    # if(str[i] == '\n') end
        addi s0, s0, 1          # char_ptr++
        j gets_loop             # loop
    
    gets_end:
        sb zero, 0(s0)          # str[i] = 0
        lw a0, 4(sp)            # load str
        lw s0, 8(sp)            # loap s0
        lw ra, 12(sp)           # load ra
        addi sp, sp, 16         # free 16
        ret                     # return str

atoi:                           # int atoi (const char *str)    
    mv a1, a0                   # a1 -> str
    li a0, 0                    # number = 0
    li a2, 1                    # signal = 1
    li a3, '0'                  # a3 = '0'
    li a4, 10                   # a4 = 10
    li t0, '-'                  # t0 = '-'
    lb t1, 0(a1)                # t1 = str[0]
    bne t1, t0, atoi_0          # if str[0] != '-' -> atoi_0

    atoi_case_negative:
        addi a1, a1, 1          # str++
        li a2, -1               # signal = -1

    atoi_0:
        lb t0, 0(a1)            # t0 = str[i]
        beq t0, zero, atoi_end  # if str[i] == '\0' -> atoi_end
        mul a0, a0, a4          # number *= 10
        sub t0, t0, a3          # t0 = int(str[i])
        add a0, a0, t0          # number += int(str[i])
        addi a1, a1, 1          # str++
        j atoi_0                # loop

    atoi_end:
        mul a0, a0, a2          # number *= signal
        ret                     # return number

itoa:                           # char *itoa ( int value, char *str, int base )
    addi sp, sp, -16
    sw a1, 12(sp)               # store str
    sw s0, 8(sp)                # store s0
    li a3, 0                    # int digits = 0 -> number of digits in str
    mv s0, a1                   # s0 = str_start
    li t0, 10                   # t0 = 10
    bne a2, t0, itoa_0          # if base != 10 -> itoa_0
    bge a0, zero, itoa_0        # if value >= 0 -> itoa_0

    itoa_base_10_negative_number:
        li t0, '-'              # t0 = '-'
        sb t0, 0(a1)            # str[0] = '-'
        li t1, -1               # t1 = -1
        mul a0, a0, t1          # value *= -1 -> becomes positive
        addi a1, a1, 1          # a1 = str + 1
        mv s0, a1               # str_start += 1

    itoa_0:
        addi a3, a3, 1          # digits++
        rem t0, a0, a2          # t0 = value % base
        sub a0, a0, t0          # value -= value % base
        div a0, a0, a2          # value /= base
        addi t0, t0, '0'        # t0 = (value % base) + '0'
        sb t0, 0(a1)            # str[i] = (value % base) + '0'
        addi a1, a1, 1          # a1 += 1
        beq a0, zero, itoa_1    # if value == 0 -> itoa_1
        j itoa_0

    itoa_1:                     # invert str
        mv a2, s0               # a2 = str_start
        sb zero, 0(a1)          # end str
        addi a1, a1, -1         # a1--

    itoa_2:                     # a1 -> right, a2 -> left
        ble a1, a2, itoa_end    # if right <= left -> itoa_end
        lb t0, 0(a1)            # t0 = str[right]
        lb t1, 0(a2)            # t1 = str[left]
        sb t0, 0(a2)            # str[left] = str[right]
        sb t1, 0(a1)            # str[right] = str[left]
        addi a1, a1, -1         # right--
        addi a2, a2, 1          # left++
        j itoa_2

    itoa_end:
        lw s0, 8(s0)            # load s0
        lw a0, 12(sp)           # load str
        addi sp, sp, 16
        ret                     # return str

exit: # void exit(int code)
    li a7, 93 # exit
    ecall

read_byte: # void read_byte(a0: null, a1: byte* buffer)
    li a0, 0            # file descriptor = 0 (stdin)
    li a2, 1            # size - Reads 1 bytes.
    li a7, 63           # syscall read (63)
    ecall
    ret

write_byte: # void write_byte(a0: null, a1: byte* b)
    li a0, 1            # file descriptor = 1 (stdout)
    li a2, 1            # size - Writes 1 bytes.
    li a7, 64           # syscall write (64)
    ecall
    ret
