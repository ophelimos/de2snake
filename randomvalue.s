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
	r11 Range
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
	.equ SIGN_MASK, 0x7fffffff

        .text

randomvalue:
        /* Init */
        movia r9, ADDR_RNG

        /* Get the random number */
        ldwio r2, 0(r9)

	/* Clear the sign bit */
	movia r8, SIGN_MASK
	and r2, r2, r8

        /* Check floor/ceiling */
        bgt r2, r4, check_ceil
check_floor:            
        /* We have a floor condition */

	/* Calculate the range of entry */
	sub r11, r5, r4

        /* Find the remainder with the range */ 
	/* n = qd + r, therefore r = n - qd */
        div r8, r11, r2 
        mul r10, r8, r2
        sub r10, r2, r10 /* r10 = remainder */
        /* Subtract the remainder from the ceiling */
        sub r2, r5, r10
	br end

check_ceil:
        blt r2, r5, end

	/* Calculate the range of entry */
	sub r11, r5, r4

        /* We have a ceiling condition */
        /* Find the remainder */
        div r8, r2, r11 
        mul r10, r8, r11
        sub r10, r2, r10 /* r10 = remainder */
        /* Add the remainder to the floor */
        add r2, r4, r10

end:    
        ret
