.globl _start

_start:
    jal main
    li a0, 0
    li a7, 93 # exit
    ecall

main:
    ret

set_pixel:            # void set_pixel(a0: uint x, a1: uint y, a2: byte color)
    slli t0, a2, 8    # t0 = color << 8
    add a2, a2, t0    # a2 = color + (color << 8)
    slli t0, t0, 8    # t0 <<= 8
    add a2, a2, t0    # a2 = [color, color, color]
    slli a2, a2, 8    # a2 = [color, color, color, 0x0]
    addi a2, a2, 0xFF # a2 = [color, color, color, 0xFF]
    li a7, 2200       # setPixel
    ecall

set_canvas_size: # void set_canvas_size(a0: uint width, a1: uint height)
    li a7, 2201  # setCanvasSize

.bss

input_file: .asciiz "image.pgm"