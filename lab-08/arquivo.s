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
    jal read            # ignore 3 bytes
    jal read
    jal read
    jal read_ascii      # a0 = read_ascii()
    la s0, size         # s0 = size
    sh a0, 0(s0)        # size[0] = a0
    jal read_ascii      # a0 = read_ascii()
    sh a0, 2(s0)        # size[1] = a0
    mv a1, a0           # a1 = height
    lh a0, 0(s0)        # a0 = width
    jal set_canvas_size # set_canvas_size(a0, a1)
    jal read_ascii      # skip next number
    jal draw_image      # call draw_image()
    lw ra, 0(sp)        # retrieve return address
    addi sp, sp, 4      # free 4 bytes
    ret

draw_image:                                 # void draw_image()
    addi sp, sp, -8                         # alloc 8 bytes
    sw ra, 0(sp)                            # store ra
    li a1, 0                                # y = 0
    draw_image_y:
        la t0, size                         # t0 = &size
        lh t0, 2(t0)                        # t0 = height
        bge a1, t0, draw_image_y_end        # if y >= height: end loop
        li a0, 0                            # x = 0
        draw_image_x:
            la t0, size                     # t0 = &size
            lh t0, 0(t0)                    # t0 = width
            bge a0, t0, draw_image_x_end    # if x >= width: end loop
            sh a0, 4(sp)                    # store x
            sh a1, 6(sp)                    # store y
            jal read                        # call read()
            la t0, current_char             # t0 = &current_char
            lb a2, 0(t0)                    # a2 = current_char
            lh a0, 4(sp)                    # retrieve x
            lh a1, 6(sp)                    # retrieve y
            jal set_pixel                   # set_pixel(x, y, current_char)
            lh a0, 4(sp)                    # retrieve x
            lh a1, 6(sp)                    # retrieve y
            addi a0, a0, 1                  # x++
            j draw_image_x                  # loop

        draw_image_x_end:
        addi a1, a1, 1                      # y++
        j draw_image_y                      # loop
    draw_image_y_end:
    lw ra, 0(sp)                            # retrieve ra
    addi sp, sp, 8                          # free 8 bytes
    ret

read_ascii:                         # int read_ascii()
    addi sp, sp, -8 # alloc 8 bytes
    sw ra, 0(sp)    # store ra
    li a0, 0 # n = 0
    while_read_ascii:
        sw a0, 4(sp) # store n
        jal read # call read
        la t0, current_char # t0 =  &current_char
        lb a1, 0(t0) # a1 = current_char
        addi a1, a1, -'0' # current_char -= '0'
        li t0, 10 # t0 = 10
        bgeu a1, t0, end_read_ascii # if current_char > 10: end loop
        lw a0, 4(sp) # retrieve n
        mul a0, a0, t0 # n *= 10
        add a0, a0, a1 # n += current_char
        j while_read_ascii # loop
    end_read_ascii:
        lw a0, 4(sp) # retrieve n
        lw ra, 0(sp)    # retrieve ra
        addi sp, sp, 8 # free 8 bytes
        ret # return n


set_pixel:            # void set_pixel(a0: uint x, a1: uint y, a2: byte color)
    andi a2, a2, 0xFF # 0xFF masks a2
    mv t0, a2
    slli a2, a2, 8
    add a2, a2, t0
    slli a2, a2, 8
    add a2, a2, t0
    slli a2, a2, 8    # a2 = [color, color, color, 0x0]
    addi a2, a2, 0xFF # a2 = [color, color, color, 0xFF]
    li a7, 2200       # syscall setPixel
    ecall
    ret

set_canvas_size: # void set_canvas_size(a0: uint width, a1: uint height)
    li a7, 2201  # syscall setCanvasSize
    ecall
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