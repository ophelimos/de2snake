/*Retrieves the colour at a point (x,y) (passed into the function in r5 and r6, respectively)
and returns it in r7*/


/* Colour codes:
 
 Black = 0
 Blue = 1
 Green = 2
 Light blue = 3
 Red = 4
 Pink = 5
 Yellow = 6 
 White = 7
 r5 is x
 r6 is y
 r7 is the returned colour
 */

.text
.global get_pixel

 .equ ADDR_VGA, 0xa00000


 
 get_pixel: 
  
  /*Sets x-value, for testing purposes */ 
#        addi r5, r0, 8 
  /*Sets y-value, for testing purposes */  
#        addi r6, r0, 4

        /*assumes r5 and r6 hold x and y, respectively*/
        muli r9, r6, 256
	add r9, r9, r5
	muli r9, r9, 4	
  
        movia r8,ADDR_VGA

        add r8, r8, r9
  
        ldwio r2,0(r8)
        ret
