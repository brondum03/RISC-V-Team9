.text
.globl main
li s0, 0x00010000
li t1, 123        # any test value
sb t1, 0(s0)

