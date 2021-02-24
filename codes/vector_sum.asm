li r0, 0
li r1, 1
li r2, 4
# Vector size
li r3, 16

# Final result: D[i] = (A[i]+B[i])*C[i]
# A
li r10, 0x10000
# B
li r11, 0x11000
# C
li r12, 0x12000

# Initialization
# i counter
li r4, 0

loopinit:
stw r4, 0(r10)
stw r4, 0(r11)
stw r4, 0(r12)

add r10, r2, r10
add r11, r2, r11
add r12, r2, r12

add r4, r1, r4
bne r4, r3, loopinit

# Calculation
# A
li r10, 0x10000
# B
li r11, 0x11000
# C
li r12, 0x12000
# D
li r13, 0x13000

# i counter
li r4, 0

loopcalc:
ldw r15, 0(r10)
ldw r16, 0(r11)
ldw r17, 0(r12)

# r18 = A[i]+B[i]
add r18, r15, r16
# r18 = (A[i]+B[i])*C[i]
mul r19, r18, r17
stw r19, 0(r13)

# Increase iterators
add r10, r2, r10
add r11, r2, r11
add r12, r2, r12
add r13, r2, r13

add r4, r1, r4
bne r4, r3, loopcalc
