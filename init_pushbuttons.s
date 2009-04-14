/* Initialize a timer at the given address to the given period*/
        
	/* Register values
	r0 0
	r1 at
	r2 Return value 1
	r3 Return value 2
	r4 Arg 1 = 
	r5 Arg 2 = 
	r6 Arg 3 = 
	r7 Arg 4

	* Can get trampled *
	r8 Temp
	r9 PUSBUTTON_ADDR
	r10 
	r11 
	r12 
	r13 
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

        .equ ADDR_PUSHBUTTONS, 0xff1090

        .text
        .global init_pushbuttons

init_pushbuttons:
        /* Enable interrupts on the device */
        movia r9, ADDR_PUSHBUTTONS
        /* Clear edge capture register */
        stwio r0, 12(r9)
        /* Enable interrupt on pushbutton 0 */
        movi r8, 0xf
        stwio r8, 8(r9)

        /* Enable IRQ5 */
        rdctl r8, ctl3
        ori r8, r8, 0x20
        wrctl ctl3, r8
end:
        ret
        