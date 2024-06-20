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
        beq t0, zero, puts_end  # if t0
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
        lw a0, 4(sp)            # load str
        lw s0, 8(sp)            # loap s0
        lw ra, 12(sp)           # load ra
        addi sp, sp, 16         # free 16
        ret                     # return str

atoi: # int atoi (const char *str)
    ret
itoa: # char *itoa ( int value, char *str, int base )
    ret

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
