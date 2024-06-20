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
        lw ra, 12(sp)           # load ra
        addi sp, sp, 16
        ret                     # return
gets: # char *gets ( char *str )
    ret
atoi: # int atoi (const char *str)
    ret
itoa: # char *itoa ( int value, char *str, int base )
    ret

exit: # void exit(int code)
    li a7, 93 # exit
    ecall

write_byte:
    li a0, 1            # file descriptor = 1 (stdout)
    li a2, 1            # size - Writes 1 bytes.
    li a7, 64           # syscall write (64)
    ecall
    ret
