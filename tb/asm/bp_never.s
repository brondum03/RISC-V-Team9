.text
.globl _start

_start:
    li      x5, 0          # t0 = 0

never_loop:
    addi    x5, x5, 1      # t0 = 1
    blt     x5, x0, never_loop    # never taken (1 < 0 is false)

    mv      x10, x5        # a0 = t0

done:
    nop
    nop
    nop
    j       done