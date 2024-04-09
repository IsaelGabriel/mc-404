.globl _start

_start:
  li a0, 234258  #<<<=== Registro do Aluno (RA)
  li a1, 0 # a1 = 0
  li a2, 0 # a2 = 0
  li a3, -1 # a3 = -1
loop:
  andi t0, a0, 1 # Bit by bit AND
  add  a1, a1, t0 # a1 += t0
  xor  a2, a2, t0 # a2 = a2 ^ t0 (Bit by bit XOR)
  addi a3, a3, 1 # a3 += 1
  srli a0, a0, 1 # Shift a0 1 bit to the right (Divide by 2) -> (Adds 0 first bit) (Removes last bit)
  bnez a0, loop # While a0 is true, return to label 'loop'

end:
  la a0, result # Loads a0 value into mem address with label 'result'
  sw a1, 0(a0)
  li a0, 0
  li a7, 93
  ecall

result:
  .word 0