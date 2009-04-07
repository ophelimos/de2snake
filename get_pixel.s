/* Retrieves the colour at a point (x,y) (passed into the function in r4 and r5, respectively)
 * and returns it in r2 */

/* Colour codes:
 
 Black = 0
 Blue = 1
 Green = 2
 Light blue = 3
 Red = 4
 Pink = 5
 Yellow = 6 
 White = 7
 r4 is x
 r5 is y
 r2 is the returned colour
 */

.text
.global get_pixel

 .equ ADDR_VGA, 0xa00000

 get_pixel: 
        /* r9 = offset */
        /* r4 = x, r5 = y */
        /* pixel (5,1) is at 4*(5+256*1) = 1041 */
        muli r9, r5, 256
	add r9, r9, r4
	muli r9, r9, 4	
  
        movia r8, ADDR_VGA
        add r8, r8, r9
  
        ldwio r2,0(r8)
        
        ret
