/* Draws a homogenous rectangle of color
        void draw_border(int start_x, int end_x, int start_y, int end_y, int color); */

        /* Register values
	r0 0
	r1 at
	r2 Return value 1
	r3 Return value 2
	r4 Arg 1 = start_x
	r5 Arg 2 = end_x
	r6 Arg 3 = start_y
	r7 Arg 4 = end_y
        Arg 5 = first argument on the stack

	* Can get trampled *
	r8 Temp
	r9 
	r10 
	r11 
	r12 
	r13 
	r14 
	r15 

	* Must be saved *
	r16 x-value
	r17 y-value
	r18 color
	r19 end_x
	r20 end_y
	r21 start_x
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

.equ BLACK, 0
.equ BLUE, 1
.equ GREEN, 2
.equ LIGHT_BLUE, 3
.equ RED, 4
.equ PINK, 5
.equ YELLOW, 6
.equ WHITE, 7 

.text
.global draw_border

.equ STACK_SIZE, 28
 
draw_border:
        /* Arg 5 (color) is on the top of the stack, so peek it */
        ldw r8, 0(sp)

        /* We call a function!  Therefore, we can't rely on values not
	changing! */
        subi sp, sp, STACK_SIZE
        stw r16, 0(sp)
        stw r17, 4(sp)
        stw r18, 8(sp)
        stw r19, 12(sp)
        stw r20, 16(sp)
        stw r21, 20(sp)
        stw ra, 24(sp)

        /* Move our peeked color value into permanent storage */
        mov r18, r8

        /* r21 = start_x */
        mov r21, r4

        /* i = start_x */
        mov r16, r4
        /* j = start_y */
        mov r17, r6
        
        /* i < end_x */
          mov r19, r5
        /* j < end_y */
          mov r20, r7
loop:
        mov r4, r16
        mov r5, r17
        mov r6, r18
  call put_pixel
        /* i++ */
  addi r16, r16, 1 

  blt r16, r19, loop

        /* i = start_x */
  mov r16, r21
        /* j++ */
  addi r17, r17, 1
  blt r17, r20, loop
  
end:
        ldw r16, 0(sp)
        ldw r17, 4(sp)
        ldw r18, 8(sp)
        ldw r19, 12(sp)
        ldw r20, 16(sp)
        ldw r21, 20(sp)
        ldw ra, 24(sp)
        addi sp, sp, STACK_SIZE

        ret
