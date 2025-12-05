.text
.globl main
main:

    # t0 = address of data (PC-relative)
    auipc t0, 0              # t0 = PC
    addi  t0, t0, data - main

    # ========== LB ==========

    lb a0, 0(t0)
    li t1, -128
    bne a0, t1, finish

    lb a0, 1(t0)
    li t1, 127
    bne a0, t1, finish

    # ========== LBU ==========

    lbu a0, 0(t0)
    li t1, 128
    bne a0, t1, finish

    lbu a0, 1(t0)
    li t1, 127
    bne a0, t1, finish

    # ========== LH ==========

    lh a0, 2(t0)
    li t1, -32768
    bne a0, t1, finish

    lh a0, 4(t0)
    li t1, 32767
    bne a0, t1, finish

    # ========== LHU ==========

    lhu a0, 2(t0)
    li t1, 32768
    bne a0, t1, finish

    lhu a0, 4(t0)
    li t1, 32767
    bne a0, t1, finish

    # ========== LW ==========

    lw a0, 6(t0)
    li t1, 0x12345678
    bne a0, t1, finish

finish:
    beq x0, x0, finish        # loop forever

###################################
# Raw test data
###################################
.data
data:
    .byte 0x80        # -128 signed, 128 unsigned
    .byte 0x7F        # 127
    .half 0x8000      # -32768 signed, 32768 unsigned
    .half 0x7FFF      # 32767
    .word 0x12345678
