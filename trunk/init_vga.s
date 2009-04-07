/* Flushes the whole screen to one particular colour, as given in r4 (first argument) */

 /* Colour codes:
 
 Black = 0
 Blue = 1
 Green = 2
 Light blue = 3
 Red = 4
 Pink = 5
 Yellow = 6 
 White = 7
 */

.text
.global init_vga

 .equ ADDR_VGA, 0xa00000

.equ STACK_SIZE, 24
 
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
  mov r18, r4

        /* i < 160 */
          addi r19, r0, 160
        /* j < 120 */
        addi r20, r0, 120
 loop:

        mov r4, r16
        mov r5, r17
        mov r6, r18
  call put_pixel
        /* i++ */
  addi r16, r16, 1  
  blt r16, r19, loop

        /* i = 0 */
  movi r16, 0
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
  