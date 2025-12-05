.text
.globl main
main:

    # --------------------------
    # ADD  (1000 + 234 = 1234)
    # --------------------------
    li t1, 1000
    li t2, 234
    add a0, t1, t2          # a0 = 1234
    li t3, 1234
    bne a0, t3, finish      # if mismatch -> fail

    # --------------------------
    # SUB  (500 - 123 = 377)
    # --------------------------
    li t1, 500
    li t2, 123
    sub a0, t1, t2          # a0 = 377
    li t3, 377
    bne a0, t3, finish

    # --------------------------
    # XOR  (0b1100 ^ 0b1010 = 0b0110 = 6)
    # --------------------------
    li t1, 12               # 1100
    li t2, 10               # 1010
    xor a0, t1, t2          # a0 = 6
    li t3, 6
    bne a0, t3, finish

    # --------------------------
    # OR  (0b1100 | 0b0011 = 0b1111 = 15)
    # --------------------------
    li t1, 12
    li t2, 3
    or a0, t1, t2           # a0 = 15
    li t3, 15
    bne a0, t3, finish

    # --------------------------
    # AND (0b1100 & 0b1010 = 0b1000 = 8)
    # --------------------------
    li t1, 12
    li t2, 10
    and a0, t1, t2          # a0 = 8
    li t3, 8
    bne a0, t3, finish

    # --------------------------
    # SLL (0x5 << 3 = 0x28 = 40)
    # --------------------------
    li t1, 5
    li t2, 3
    sll a0, t1, t2          # a0 = 40
    li t3, 40
    bne a0, t3, finish

    # --------------------------
    # SRL (128 >> 3 = 16)
    # --------------------------
    li t1, 128
    li t2, 3
    srl a0, t1, t2          # logical shift
    li t3, 16
    bne a0, t3, finish

    # --------------------------
    # SRA  (-64 >> 2 = -16)
    # --------------------------
    li t1, -64
    li t2, 2
    sra a0, t1, t2          # arithmetic shift
    li t3, -16
    bne a0, t3, finish

    # --------------------------
    # SLT  (signed compare)
    # -5 < 7 → a0 = 1
    # --------------------------
    li t1, -5
    li t2, 7
    slt a0, t1, t2
    li t3, 1
    bne a0, t3, finish

    # --------------------------
    # SLTU (unsigned compare)
    # 0xFFFFFFFF > 0x00000001 → a0 = 0
    # --------------------------
    li t1, -1               # 0xFFFFFFFF (unsigned huge)
    li t2, 1
    sltu a0, t1, t2         # unsigned: 0xFFFFFFFF > 1 → result 0
    li t3, 0
    bne a0, t3, finish

finish:
    # Final state: a0 = 0 (last SLTU result)
    bne a0, a0, finish      # infinite loop

