li r1, 1
li r2, 1
li r3, 1
li r4, 1
li r5, 2
li r6, 65536
li r7, 1
li r8, 1

loopinit:
mul r1, r1, r5
mul r1, r1, r5
mul r1, r1, r5
mul r1, r1, r5
mul r2, r2, r5
mul r2, r2, r5
mul r2, r2, r5
mul r2, r2, r5
mul r3, r3, r5
mul r3, r3, r5
mul r3, r3, r5
mul r3, r3, r5
mul r4, r4, r5
mul r4, r4, r5
mul r4, r4, r5
mul r4, r4, r5
mul r7, r7, r5
mul r7, r7, r5
mul r7, r7, r5
mul r7, r7, r5
mul r8, r8, r5
mul r8, r8, r5
mul r8, r8, r5
mul r8, r8, r5

bne r1, r6, loopinit