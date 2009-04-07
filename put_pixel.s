/* Writes colour to VGA, given inputs x, y, and colour, respectively stored
in registers r4, r5, and r6 */

.equ BLACK, 0
.equ BLUE, 1
.equ GREEN, 2
.equ LIGHT_BLUE, 3
.equ RED, 4
.equ PINK, 5
.equ YELLOW, 6
.equ WHITE, 7 
.equ ADDR_VGA, 0xa00000

.text
.global put_pixel



put_pixel: 
        /* Doesn't call anything, so we don't need to store ra */
        
offset: 
        /* r3 = offset */
        /* r4 = x, r5 = y, r6 = color */
        /* pixel (5,1) is at 4*(5+256*1) = 1041 */
	muli r3, r5, 256
	add r3, r3, r4
	muli r3, r3, 4
  
        movia r2,ADDR_VGA
        add r2, r2, r3
        stwio r6,0(r2)
        
after:
        ret
        