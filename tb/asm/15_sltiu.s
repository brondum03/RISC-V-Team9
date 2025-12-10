.text
.globl main
main:
    # Test SLTIU - all results in a0
    
    # Load test value: t0 = 0xFFFFFFFF = -1 signed, 4294967295 unsigned
    lui t0, 0xFFFFF         # Load upper bits of -1
    addi t0, t0, -1         # t0 = 0xFFFFFFFF
    
    # TEST 1: Most obvious failure case
    # Signed: -1 < 0 = true (1)
    # Unsigned: 4294967295 < 0 = false (0)
    sltiu a0, t0, 0         # a0 should be 0 if correct, 1 if buggy
    
    # If a0 == 0, SLTIU is correct (unsigned comparison)
    # If a0 == 1, SLTIU is buggy (doing signed comparison like SLTI)
    
    j finish

finish:
    # Loop forever
    # Check a0 value:
    #   a0 = 0: SLTIU implemented correctly (unsigned comparison)
    #   a0 = 1: SLTIU buggy (signed comparison)
    j finish

    