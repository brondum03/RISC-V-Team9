.text
.globl _start

_start:
    li      x5, 0          # t0 = counter
    li      x6, 10         # t1 = limit

always_loop:
    addi    x5, x5, 1      # t0++
    blt     x5, x6, always_loop

    mv      x10, x5        # a0 = t0 (copy result to a0 for test)

done:
    nop
    nop
    nop
    j       done