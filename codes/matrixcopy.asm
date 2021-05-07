li r0, 0
li r1, 1
li r1, 1
li r1, 1
li r2, 4

#ROWS
li r3, 4 
#COLS
li r4, 4 

# A
li r10, 0x10000

# Initialization
# i counter
li r5, 0

mul r6, r3, r4

loopinit:
stw r5, 0(r10)

add r10, r2, r10

add r5, r1, r5
bne r5, r6, loopinit


#Transpose

#FALTA MULTIPLICAR PER 4 L'OFFSET!

# A
li r10, 0x10000
# A trans
li r11, 0x11000

#j counter
li r6, 0

loopi:
#i counter
li r5, 0  
loopj:

# index A BA + i + j*COLS
mul r12, r6, r4
add r13, r12, r5
mul r14, r13, r2
add r15, r14, r10 

ldw r20, 0(r15)

# index A trans BA + i*ROWS + j
mul r16, r5, r3
add r17, r16, r6
mul r18, r17, r2
add r19, r18, r11


stw r20, 0(r19)

add r5, r1, r5
bne r5, r4, loopj

add r6, r1, r6
bne r6, r3, loopi