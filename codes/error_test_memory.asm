li r1, 1
li r2, 2
li r3, 3
li r4, 4
li r5, 0x10000

stw r1, 0(r5)
stw r2, 4(r5)
stw r3, 8(r5)
stw r4, 12(r5)
stw r1, 16(r5)
stw r2, 20(r5)
stw r3, 24(r5)
stw r4, 28(r5)

ldw r5, 0(r5)
ldw r6, 4(r5)
ldw r7, 8(r5)
ldw r8, 12(r5)
ldw r9, 16(r5)
ldw r10, 20(r5)
ldw r11, 24(r5)
ldw r12, 28(r5)
