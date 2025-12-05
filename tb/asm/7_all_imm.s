.text
.globl main
main:

    # --------------------------
    # ADDI   (1000 + (-123) = 877)
    # --------------------------
    li t1, 1000
    addi a0, t1, -123       # a0 = 877
    li t3, 877
    bne a0, t3, finish

    # --------------------------
    # XORI   (0b1100 ^ 0b0101 = 0b1001 = 9)
    # --------------------------
    li t1, 12               # 1100
    xori a0, t1, 5          # a0 = 9
    li t3, 9
    bne a0, t3, finish

    # --------------------------
    # ORI    (0b1100 | 0b0011 = 0b1111 = 15)
    # --------------------------
    li t1, 12               # 1100
    ori a0, t1, 3           # a0 = 15
    li t3, 15
    bne a0, t3, finish

    # --------------------------
    # ANDI   (0b1100 & 0b1010 = 0b1000 = 8)
    # --------------------------
    li t1, 12
    andi a0, t1, 10         # a0 = 8
    li t3, 8
    bne a0, t3, finish

    # --------------------------
    # SLLI   (5 << 3 = 40)
    # --------------------------
    li t1, 5
    slli a0, t1, 3          # a0 = 40
    li t3, 40
    bne a0, t3, finish

    # --------------------------
    # SRLI   (128 >> 3 = 16)
    # --------------------------
    li t1, 128
    srli a0, t1, 3          # a0 = 16
    li t3, 16
    bne a0, t3, finish

    # --------------------------
    # SRAI   (-64 >> 2 = -16) // in a different assembly file
    # --------------------------

    # --------------------------
    # SLTI   (-5 < 7 → 1)
    # --------------------------
    li t1, -5
    slti a0, t1, 7          # signed comparison
    li t3, 1
    bne a0, t3, finish

    # --------------------------
    # SLTIU   (0xFFFFFFFF < 1 ? false → 0)
    # --------------------------
    li t1, -1               # 0xFFFFFFFF unsigned
    sltiu a0, t1, 1         # unsigned compare → false
    li t3, 0
    bne a0, t3, finish


finish:
    # Final expected result = 
    bne a0, a0, finish      # infinite loop
