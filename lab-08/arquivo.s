.globl _start

_start:
    jal main
    li a0, 0
    li a7, 93 # exit
    ecall

main:
    addi sp, sp, -4 # alloc 4 bytes
    sw ra, 0(sp)    # store return address
    jal open        # call open()
    la a1, fd       # a1 = fd
    sw a0, 0(a1)    # *fd = open()
    lw ra, 0(sp)    # retrieve return address
    addi sp, sp, 4  # free 4 bytes
    ret

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

open:                    # fd open()
    la a0, input_file    # address for the file path
    li a1, 0             # flags (0: rdonly, 1: wronly, 2: rdwr)
    li a2, 0             # mode
    li a7, 1024          # syscall open 
    ecall
    ret

.bss

input_file: .asciiz "image.pgm"

fd: .skip 0x04 # file descriptor