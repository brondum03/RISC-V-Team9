.text
.globl main
main:
    addi t2, x0, 0x100      # t2 = 0x100
    
    lui t1, 0x87654          # t1 = 0x87654000
    addi t1, t1, 0x321       # t1 = 0x87654321
    
    sb t1, 0(t2) # grab the first byte so 21

    # load the full word to see if it was really just hte byte that got picked up
    lw a0, 0(t2)
    addi t3, x0, 0x21
    bne a0, t3, fail

    # Success: a0 = 1
    addi a0, x0, 1
    j end
    
fail:
    addi a0, x0, 2
    
end:
    j end

