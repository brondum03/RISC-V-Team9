.text
.globl main

.equ base_data, 0x10000

main:
    li   t0, base_data

    lbu  t1, 0(t0)     # byte 0
    lbu  t2, 1(t0)     # byte 1
    lbu  t3, 2(t0)     # byte 2
    lbu  t4, 3(t0)     # byte 3

    add  a0, t1, t2
    add  a0, a0, t3
    add  a0, a0, t4

end:
    bne  zero, zero, end  # loop forever