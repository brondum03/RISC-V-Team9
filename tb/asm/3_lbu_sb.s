.text
.globl main
main:
    li s0, 0x00010000   # create pointer to base of data array

    li t1, 100      #                                    06400313
    sb t1, 0(s0)    # store 100 at address 0x00010000   00640023
    li t2, 200      #                                    0C800393
    sb t2, 4(s0)    # store 200 at address 0x00010001   00740223

    lbu t4, 4(s0)   #                       (=200)      00444E83
    lbu t3, 0(s0)   #                       (=100)      00044E03
    add a0, t3, t4  # a0 = t3 + t4          (=300)      01D50533
    bne     a0, zero, finish    # enter finish state

finish:     # expected result is 300
    bne     a0, zero, finish     # loop forever
