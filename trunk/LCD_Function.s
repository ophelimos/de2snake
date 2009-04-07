
.data


.equ LCD_DISPLAY, 0xff1060




.text
.global main

main:


movia r7, LCD_DISPLAY


movi r3, 1
stwio r3, 0(r7) /*Clears the screen*/


loop: 



ldb r3, 0(r4)

stbio r3, 4(r7)

addi r2, r2, 1
 
bne r0, r3, loop /*When NULL is seen, exit the loop*/




ret



