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
    ret
gets: # char *gets ( char *str )
    ret
atoi: # int atoi (const char *str)
    ret
itoa: # char *itoa ( int value, char *str, int base )
    ret

exit: # void exit(int code)
    li a7, 93 # exit
    ecall