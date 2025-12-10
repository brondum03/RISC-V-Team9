.text
.globl main
main:
    addi t2, x0, 0x100      # t2 = 0x100
    
    lui t1, 0x87654          # t1 = 0x87654000
    addi t1, t1, 0x321       # t1 = 0x87654321
    
    sw t1, 0(t2)
    
    # Test all bytes
    lb a0, 0(t2)
    addi t3, x0, 33
    bne a0, t3, fail
    
    lb a0, 1(t2)
    addi t3, x0, 67
    bne a0, t3, fail
    
    lb a0, 2(t2)
    addi t3, x0, 101
    bne a0, t3, fail
    
    lb a0, 3(t2)
    addi t3, x0, -121 #sign extends and is therefore a negative number
    bne a0, t3, fail
    
    # Success: a0 = 1
    addi a0, x0, 1
    j end
    
fail:
    # Failure: a0 = 2
    addi a0, x0, 2
    
end:
    j end

    