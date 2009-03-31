/*Flushes the whole screen to one particular colour*/


.include "put_pixel.s"
 
.equ BLACK, 0
.equ BLUE, 1
.equ GREEN, 2
.equ LIGHT_BLUE, 3
.equ RED, 4
.equ PINK, 5
.equ YELLOW, 6
.equ WHITE, 7 

.equ MAX_X, 160
.equ MAX_Y, 120
.equ X_EDGE, 156
.equ Y_EDGE, 116

.text
.global main

 .equ ADDR_VGA, 0xa00000

.equ STACK_SIZE, 24
 
 main:
 
 movia r6, GREEN
 init_vga:

        /* We call a function!  Therefore, we can't rely on values not
	changing! */
        subi sp, sp, STACK_SIZE
        stw r16, 0(sp)
        stw r17, 4(sp)
        stw r18, 8(sp)
        stw r19, 12(sp)
        stw r20, 16(sp)
        stw ra, 20(sp)
  
  addi r16, r0, 0
  addi r17, r0, 0
  addi r18, r0, 0

        /* i < 160 */
          addi r19, r0, MAX_X
        /* j < 120 */
        addi r20, r0, MAX_Y
 loop1:

        mov r4, r16
        mov r5, r17
        
  call put_pixel
        /* i++ */
  addi r16, r16, 1 

  blt r16, r19, loop

        /* i = 0 */
  movi r16, 0
        /* j++ */
  addi r17, r17, 1
  blt r17, r20, loop
  
  end1:
        ldw r16, 0(sp)
        ldw r17, 4(sp)
        ldw r18, 8(sp)
        ldw r19, 12(sp)
        ldw r20, 16(sp)
        ldw ra, 20(sp)
        addi sp, sp, STACK_SIZE

 
 
 
 
 
 

 movi r6, BLUE
        
        subi sp, sp, STACK_SIZE
        stw r16, 0(sp)
        stw r17, 4(sp)
        stw r18, 8(sp)
        stw r19, 12(sp)
        stw r20, 16(sp)
        stw ra, 20(sp)
  
  addi r16, r0, 4
  addi r17, r0, 4
  addi r18, r0, 4

        /* i < 156 */
          addi r19, r0, X_EDGE
        /* j < 116 */
        addi r20, r0, Y_EDGE
 loop:

        mov r4, r16
        mov r5, r17
        mov r6, r18
  call put_pixel
        /* i++ */
  addi r16, r16, 1  
  blt r16, r19, loop

        /* i = 0 */
  movi r16, 4
        /* j++ */
  addi r17, r17, 1
  blt r17, r20, loop
  
  end:
        ldw r16, 0(sp)
        ldw r17, 4(sp)
        ldw r18, 8(sp)
        ldw r19, 12(sp)
        ldw r20, 16(sp)
        ldw ra, 20(sp)
        addi sp, sp, STACK_SIZE

		

        ret
  