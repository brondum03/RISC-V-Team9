.text
.globl main
main:

    # --------------------------
    # SRAI   (-64 >> 2 = -16)
    # --------------------------
    li t1, -64
    srai a0, t1, 2          # arithmetic right shift
    li t3, -16
    bne a0, t3, finish

finish:
    # Final expected result = -16
    bne a0, a0, finish      # infinite loop
