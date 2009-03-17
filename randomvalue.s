/* Write a random value between two numbers, using the DE2's RNG */
        
        /* Register values
	r0 0
	r1 at
	r2 Return value 1
	r3 Return value 2
	r4 Arg 1 = floor
	r5 Arg 2 = ceiling
	r6 Arg 3 = 
	r7 Arg 4

	* Can get trampled *
	r8 Temp
	r9 ADDR_RNG
	r10 Remainder
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

        .global randomvalue
        .equ ADDR_RNG, 0xff11a0

        .text

randomvalue:
        /* Init */
        movia r9, ADDR_RNG

        /* Get the random number */
        ldwio r2, 0(r9)

        /* Check floor/ceiling */
        bgt r2, r4, check_ceil
        /* We have a floor condition */
        /* Find the remainder */
        div r8, r2, r4 ; The original div operation
        mul r10, r8, r4
        sub r10, r2, r10 ; r10 = remainder
        /* Subtract the remainder from the ceiling */
        sub r2, r4, r10

check_ceil:
        blt r2, r5, end
        /* We have a ceiling condition */
        /* Find the remainder */
        div r8, r2, r5 ; The original div operation
        mul r10, r8, r5
        sub r10, r2, r10 ; r10 = remainder
        /* Add the remainder to the floor */
        add r2, r5, r10

end:    
        ret
