/* Loads a c-string into the LCD screen */
        
.data


.equ LCD_DISPLAY, 0xff1060




	.text
	.global print_lcd

print_lcd:


	movia r7, LCD_DISPLAY


	movi r3, 1
	stwio r3, 0(r7) /* Clears the screen */

        /* Load the first byte beforehand */
        ldb r3, 0(r4)
        /* If it's NULL, break immediately */
        bne r3, r0, loop
        ret

loop: 
	stbio r3, 4(r7)
        
        /* Also increment the pointer */
        addi r4, r4, 1
	addi r2, r2, 1

        ldb r3, 0(r4)
	bne r0, r3, loop /*When NULL is seen, exit the loop*/




	ret

