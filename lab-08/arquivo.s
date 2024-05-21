.globl _start

_start:
    jal main
    li a0, 0
    li a7, 93 # exit
    ecall

main:
    addi sp, sp, -4     # alloc 4 bytes
    sw ra, 0(sp)        # store return address
    jal open            # call open()
    la a1, fd           # a1 = fd
    sw a0, 0(a1)        # *fd = open()
    li a0, 3            # a0 = 0
    jal skip_chars      # skip first 3 chars
    jal read_ascii      # a0 = read_ascii()
    la s0, size         # s0 = size
    sh a0, 0(s0)        # size[0] = a0
    jal read            # skip 1 char
    jal read_ascii      # a0 = read_ascii()
    sh a0, 2(s0)        # size[1] = a0
    mv a1, a0           # a1 = height
    lh a0, 0(s0)        # a0 = width
    jal set_canvas_size # set_canvas_size(a0, a1)
    jal read            # skip 1 char
    jal read_ascii      # skip next number
    jal read            # skip 1 char
    jal draw_image      # call draw_image()
    lw ra, 0(sp)        # retrieve return address
    addi sp, sp, 4      # free 4 bytes
    ret

draw_image:                                     # void draw_image()
    addi sp, sp, -8                             # alloc 8 bytes
    sw ra, 0(sp)                                # store ra
    li a1, 0                                    # y = 0
    for_y_in_draw_image:
        la t0, size                             # t0 = &size
        lh t0, 2(t0)                            # t0 = height
        bge a1, t0, end_draw_image              # if y >= height: end y loop
        li a0, 0                                # x = 0
        for_x_in_draw_image:
            la t0, size                         # t0 = &size
            lh t0, 0(t0)                        # t0 = width
            bge a0, t0, end_for_x_in_draw_image # if x >= width: end x loop
            sh a0, 4(sp)                        # store x
            sh a1, 6(sp)                        # store y
            jal read                            # read
            lh a0, 4(sp)                        # retrieve x
            lh a1, 6(sp)                        # retrieve y
            la t0, current_char                 # t0 = &current_char
            lb a2, 0(t0)                        # a2 = current_char
            addi a2, a2, -'0'                   # a2 -= '0'
            jal set_pixel                       # call set_pixel(x, y, current_char)
            jal read                            # skip 1 char
            lh a0, 4(sp)                        # retrieve x
            lh a1, 6(sp)                        # retrieve y
            addi a0, a0, 1                      # x++
            j for_x_in_draw_image               # x loop
        end_for_x_in_draw_image:
            addi a1, a1, 1                      # y++
            j for_y_in_draw_image               # y loop

    end_draw_image:
        lw ra, 0(sp)                            # retrieve ra
        addi sp, sp, 8                          # free 8 bytes
        ret

read_ascii:                         # int read_ascii()
    addi sp, sp, -8                 # alloc 8 bytes
    sw ra, 0(sp)                    # sp[0] = ra
    li a0, 0                        # n = 0

    while_read_ascii:
        sw a0, 4(sp)                # sp[1] = n
        jal read                    # call read()
        la t0, current_char         # t0 = &current_char
        lw a0, 4(sp)                # a0 = n
        lb a1, 0(t0)                # a1 = current_char
        addi a1, a1, -'0'           # a1 -= '0'
        li t0, 9                    # t0 = 9
        bgtu a1, t0, end_read_ascii # if current_char > 9: end loop
        li t0, 10                   # t0 = 10
        mul a0, a0, t0              # n *= 10
        add a0, a0, a1              # n += current_char
        j while_read_ascii          # loop


    end_read_ascii:
        lw ra, 0(sp)                # ra = sp[0]
        addi sp, sp, 8              # free 8 bytes
        ret                         # return n


set_pixel:            # void set_pixel(a0: uint x, a1: uint y, a2: byte color)
    slli t0, a2, 8    # t0 = color << 8
    add a2, a2, t0    # a2 = color + (color << 8)
    slli t0, t0, 8    # t0 <<= 8
    add a2, a2, t0    # a2 = [color, color, color]
    slli a2, a2, 8    # a2 = [color, color, color, 0x0]
    addi a2, a2, 0xFF # a2 = [color, color, color, 0xFF]
    li a7, 2200       # syscall setPixel
    ecall
    ret

set_canvas_size: # void set_canvas_size(a0: uint width, a1: uint height)
    li a7, 2201  # syscall setCanvasSize
    ret

skip_chars:                         # void skip_chars(a0: n)
    addi sp, sp, -8                 # alloc 8 bytes [4 for ra, 4 for a0]
    sw ra, 0(sp)                    # sp[0] = ra
    li a1, 0                        # i = 0
    for_i_skip_chars:
        bge a1, a0, end_skip_chars  # for(int i = 0; i < n; i++)
        sw a0, 4(sp)                # sp[1] = n
        jal read                    # read()
        lw a0, 4(sp)                # a0 = n
        addi a1, a1, 1              # i++
        j for_i_skip_chars
    
    end_skip_chars:
        lw ra, 0(sp)                # ra = sp[0]
        addi sp, sp, 8              # free 8 bytes
        ret

read:                   # void read()
    la a0, fd           # a0 = fd
    lw a0, 0(a0)        # a0 = *fd
    la a1, current_char # a1 = current_char
    li a2, 1            # size = 1
    li a7, 63           # syscall read
    ecall
    ret

open:                    # fd open()
    la a0, input_file    # address for the file path
    li a1, 0             # flags (0: rdonly, 1: wronly, 2: rdwr)
    li a2, 0             # mode
    li a7, 1024          # syscall open 
    ecall
    ret

.data

input_file: .asciz "image.pgm"

.bss

fd: .skip 0x04 # file descriptor

current_char: .skip 0x01 # current read char from file

size: .skip 0x04 # short size[2]