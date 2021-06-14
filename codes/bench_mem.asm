li r1, 1
li r24, 0x10000
li r25, 1
li r26, 4

loopinit:
stw r1, 0(r24)
ldw r2, 0(r24)
stw r2, 4(r24)
ldw r3, 4(r24)
stw r3, 8(r24)
ldw r4, 8(r24)
stw r4, 12(r24)
ldw r5, 12(r24)
stw r5, 16(r24)
ldw r6, 16(r24)
stw r6, 20(r24)
ldw r7, 20(r24)
stw r7, 24(r24)
ldw r8, 24(r24)
stw r8, 28(r24)
ldw r9, 28(r24)
stw r9, 32(r24)
ldw r10, 32(r24)
stw r10, 36(r24)
ldw r11, 36(r24)
stw r11, 40(r24)
ldw r12, 40(r24)
stw r12, 44(r24)
ldw r13, 44(r24)
stw r13, 48(r24)
ldw r14, 48(r24)
stw r14, 52(r24)
ldw r15, 52(r24)
stw r15, 56(r24)
ldw r16, 56(r24)
stw r16, 60(r24)
ldw r17, 60(r24)
stw r17, 64(r24)
ldw r18, 64(r24)
stw r18, 68(r24)

add r1, r1, r25
bne r1, r26, loopinit