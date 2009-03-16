/* Get either the character that was just pressed, or return 0.  Returns -1 on error. */
        
        /* Register values
	r0 0
	r1 at
	r2 Return value 1
	r3 Return value 2
	r4 Arg 1 = Array Address
	r5 Arg 2 = Array length
	r6 Arg 3 = Character to delete from array
	r7 Arg 4

	* Can get trampled *
	r8 Temp
	r9 PS2ADDR
	r10 KEYBOARD_INT
	r11 Byte read from keyboard
	r12 Extended key code
	r13 Break code
	r14 
	r15 

	* Must be saved *
	r16 
	r17 
	r18
	r19 
	r20
	r21 
	r22 
	r23
	
	r24 et
	r25 bt
	r26 gp
	r27 sp
	r28 fp
	r29 ea
	r30 ba
	r31 ra
	*/
        
        .equ PS2ADDR, 0xff1150
        .equ EXTENDED_KEY, 0xEO
        .equ BREAK_CODE, 0xF0

        .text

        .global getch

getch:
        /* init */
        movia r9, PS2ADDR
        movia r10, KEYBOARD_INT
        movi r12, EXTENDED_KEY
        movi r13, BREAK_CODE

        /* Check if the keyboard has interrupted */
        ldwio r8, 0(r10)
        bne r8, r0, have_key
        /* Otherwise, return 0 */
        movi r2, 0
        ret

have_key:
        /* Read the byte */
        ldwio r11, 0(r9)
        /* Check for errors */
        ldwio r8, 4(r9)
        andi r8, 0x400
        beq r8, r0, no_errors
        /* Otherwise, return -1 */
        movi r2, -1
        ret

no_errors:
        /* Mask the byte */
        andi r11, 0xFF
        /* Check if it's an extended key */
        