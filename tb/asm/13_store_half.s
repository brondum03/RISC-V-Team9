.text
.globl main
main:
    addi t2, x0, 0x100      # t2 = 0x100
    
    lui t1, 0x87654          # t1 = 0x87654000
    addi t1, t1, 0x321       # t1 = 0x87654321
    
    sh t1, 0(t2) # grab the first half so 4321

    # load the full word to see if it was really just hte byte that got picked up
    lw a0, 0(t2)
    lui t3, 0x00004
    addi t3, t3, 0x321
    bne a0, t3, fail

    # Success: a0 = 1
    addi a0, x0, 1
    j end
    
fail:
    addi a0, a0, 1
    
end:
    j end

