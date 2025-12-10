.text
.globl main
main:
    addi t2, x0, 0x100
    
    # Store: 0x01007180
    
    lui t1, 0x01007         # t1 = 0x01007000
    addi t1, t1, 0x180      # t1 = 0x01007180
    
    sw t1, 0(t2)
    
    # Test LW: should get 0x01007180 --> 29056
    lw a0, 0(t2) 
    lui t3, 0x01007
    addi t3, t3, 0x180
    bne a0, t3, fail
    
    # Success
    j end
    
fail:
    addi a0, a0, 1
    
end:
    j end

