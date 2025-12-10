.text
.globl main
main:
    li s0, 0x00010000       # base pointer

    li t1, 100              # 06400313
    sb t1, 0(s0)            # 00640023

    li t2, 200              # 0C800393
    sb t2, 4(s0)            # 00740223

    lbu t4, 4(s0)           # load 200     00444E83

    addi x0, x0, 0          # --- NOP inserted here ---

    lbu t3, 0(s0)           # load 100     00044E03

    add a0, t3, t4          # 01D50533

    bne a0, zero, finish

finish:
    bne a0, zero, finish
