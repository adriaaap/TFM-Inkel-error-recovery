li r1, 0
li r2, 0
li r3, 0
li r4, 0
li r5, 32
li r7, 1

loopinit:
add r1, r1, r7
add r2, r2, r7
add r2, r2, r7
add r3, r3, r7
add r3, r3, r7
add r3, r3, r7
add r4, r4, r7
add r4, r4, r7
add r4, r4, r7
add r4, r4, r7

bne r1, r5, loopinit