    .text
    .globl main
main:
    li  t0, 0x100      # base_pdf
    li  t1, 0          # expected value
    li  t4, 200        # loop bound

loop:
    lbu t2, 0(t0)      # load bin
    addi t2, t2, 1
    sb  t2, 0(t0)      # store back

    lbu t3, 0(t0)      # IMMEDIATE reload
    bne t3, t2, fail   # must match

    addi t1, t1, 1
    bne  t1, t4, loop

pass:
    li a0, 1
    j end

fail:
    li a0, 0           # if this triggers, store→load is broken

end:
    j end