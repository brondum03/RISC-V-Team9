.text
.globl _start

_start:
    li      x5, 0          # t0 = counter
    li      x6, 10         # t1 = limit
    li      x7, 1          # t2 = toggle

alt_loop:
    beqz    x7, alt_skip   # if toggle == 0, skip
    addi    x7, x7, -1     # toggle = 0
    j       alt_next

alt_skip:
    addi    x7, x7, 1      # toggle = 1

alt_next:
    addi    x5, x5, 1      # counter++
    blt     x5, x6, alt_loop

    mv      x10, x5        # a0 = t0

done:
    nop
    nop
    nop
    j       done