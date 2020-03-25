li r0, 0
li r1, 1
li r2, 2
li r3, 3


init:
bne r0, r0, end
bne r1, r1, end
bne r2, r2, end
bne r2, r3, end

mov r2, r3
mov r1, r2
mov r0, r1
mov r3, r0

end:
mov r2, r3
mov r1, r2
mov r0, r1
mov r3, r0