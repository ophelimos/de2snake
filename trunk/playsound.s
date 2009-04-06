/* Play a sound from a wave file */
        
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
	r9 AUDIO_ADDR
	r10 
	r11 
	r12 AUDIO_ENABLE
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

        .equ AUDIO_ADDR, 0xff11160
        .equ AUDIO_ENABLE, 0x1 /* Enable  */

        .text
        .global init_timer

init_timer:
        /* Clock init */
        /* Set up the clock period */
        stwio r5, 8(r4)
        srli r5, r5, 16
        stwio r5, 12(r4)
        movi r12, TIMER_START

        /* Start timer, and enable timer interrupts at the same time */
        stwio r12, 4(r4)

        /* Enable IRQ (line 3 for timer0, line 4 for timer1) */
        /* Only timer0 for now */
#        movia r9, TIMER_ADDR
#        beq r4, r9, timer0*/
timer0: /* line 3 */
        rdctl r8, ctl3
        ori r8, r8, 0x8
        wrctl ctl3, r8
#        br end
#timer1: /* line 4 */
#        rdctl r8, ctl3
#        ori r8, r8, 0x10
#        wrctl ctl3, r8
end:
        ret
        