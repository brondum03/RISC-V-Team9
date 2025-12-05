# cycles through 9 states through bit encoding
# state sequence:
# S0: 8'b00000000
# S1: 8'b00000001
# S2: 8'b00000011
# S3: 8'b00000111
# S4: 8'b00001111
# S5: 8'b00011111
# S6: 8'b00111111
# S7: 8'b01111111
# S8: 8'b11111111

# registers description:
# a0 - current state bit pattern
# a1 - reset flags
# a2 - sequence running flag (enable)
# t1 - constant 0xFF for detection
# t2 - delay counter
# t3 - for XOR comparison (to check if a0 == 0xFF)
# t4 - LFSR state
# t5 - temporary for LFSR operations and delay
# t6 - constant 10 


# instructions tested:
# arithmetic : addi, sub, add
# logic      : ori, andi, xori
# set/compare: snez, seqz, blt 
# branches   : bnez (bne), bne, beqz (beq)
# jumps      : j (jal)
# memory     : li (lui + addi)
# shifts     : slli, srli

.text
.globl main
main:
    li      a0, 0                   # start at S0 (0x00)
    li      t1, 0xFF                # S8 detection value
    li      t4, 0b1011010           # LFSR seed

state_loop:
    li      t2, 10                  # load delay counter (10 iterations ~ 1 second)

delay_loop:
    addi    t2, t2, -1              # decrement delay counter
    bnez    t2, delay_loop          # if counter != 0, loop back
    
    # set output flags
    snez    a2, a0                  # a2 = 1 if a0 != 0
    xori    t3, a0, 0xFF            # check if a0 == 0xFF
    seqz    a1, t3                  # a1 = 1 if t3 == 0, i.e. a0 == 0xFF
    
    bne     a0, t1, next_state      # if a0 != 0xFF, jump to next_state
    
    # LFSR for random delay at S8
    andi    t5, t4, 1               
    srli    t4, t4, 1
    beqz    t5, lfsr_skip
    xori    t4, t4, 0b10100000
lfsr_skip:
    li      t6, 10                  

    add     t5, t4, zero
mod_loop:
    blt     t5, t6, mod_done
    sub     t5, t5, t6              # t5 = t5 - 10
    j       mod_loop
mod_done:
    addi    t5, t5, 1

random_delay:
    addi    t5, t5, -1
    bnez    t5, random_delay
    
    li      a0, 0                  # reset to s0
    j       state_loop            

next_state:
    slli    a0, a0, 1              # multiply a0 by 2
    ori     a0, a0, 1              # set LSB as 1
    j       state_loop


