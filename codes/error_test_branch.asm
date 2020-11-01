li r1, 0
li r2, 1
li r3, 2
li r4, 3


init:
bne r1, r1, end
bne r2, r2, end
bne r3, r3, end
bne r3, r4, end

mov r3, r4
mov r2, r3
mov r1, r2
mov r4, r1

end:
mov r3, r4
mov r2, r3
mov r1, r2
mov r4, r1