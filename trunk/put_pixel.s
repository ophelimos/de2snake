/*Writes colour to VGA, given inputs x, y, and colour, respectively stored
in registers r5, r6, and r7*/



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
.global put_pixel

.equ ADDR_VGA, 0xa00000

put_pixel: 
        /* Doesn't call anything, so we don't need to store ra */
        
offset: 
        /* r3 = offset */
        /* r4 = x, r5 = y, r6 = color */
        /* pixel (4,1) is at 4*(4+256*1) = 1040 */
	muli r3, r5, 256
	add r3, r3, r4
	muli r3, r3, 4
  
        movia r2,ADDR_VGA
        add r2, r2, r3
        stwio r6,0(r2)
        
  after:
        ret
        