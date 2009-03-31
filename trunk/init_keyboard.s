/* Keyboard initialization 
        (from http://www-ug.eecg.toronto.edu/msl/nios_devices/datasheets/PS2%20Keyboard%20Protocol.htm) */

	/* Register values
	r0 0
	r1 at
	r2 Return value 1
	r3 Return value 2
	r4 Arg 1
	r5 Arg 2
	r6 Arg 3
	r7 Arg 4

	* Can get trampled *
	r8 Temp
	r9 PS2ADDR
	r10 KEYBOARD_INT
	r11 Self-test correct
	r12 ACK
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
        
        .equ PS2ADDR, 0xff1150
        .equ TIMER0_ADDR, 0xff1020

        /* Make a global variables that will act as interrupt flags */
KEYBOARD_INT:   
        .byte 0x0
        .global KEYBOARD_INT

TIMER_INT:   
        .byte 0x0
        .global TIMER_INT

        /* Exceptions section */

        .section .exceptions, "ax"
        .equ INTERRUPT_STACK, 16
        
exception_handler:
        /* Save *all* used registers to the stack */
        /* r8 = ipending */
        /* r9 = masked answer/temp */
        /* r10 = flag address */
        /* r11 = device address */
        subi sp, sp, INTERRUPT_STACK
        stw r8, 0(sp)
        stw r9, 4(sp)
        stw r10, 8(sp)
        stw r11, 12(sp)
        
        /* Find out what device caused the interrupt */
        rdctl r8, ctl4
        /* Check keyboard first (IRQ11) */
        andi r9, r8, 0x800
        beq r9, r0, check_timer0
        /* Load the data (acknowledging the interrupt) */
        movia r11, PS2ADDR
        ldwio r9, 0(r11)
        andi r9, r9, 0xFF
        movia r10, KEYBOARD_INT
        stb r9, 0(r10)
        
check_timer0:   
        /* Check timer0 (IRQ3)*/
        andi r9, r8, 0x8
        beq r9, r0, end_exc
        /* Acknowledge the interrupt (by clearing the timer) */
        movia r11, TIMER0_ADDR
        stwio r0, 0(r11)
        /* Set the flag */
        movia r10, TIMER_INT
        movi r9, 0x1
        stb r9, 0(r10)
        
end_exc:
        /* Restore registers */
        ldw r8, 0(sp)
        ldw r9, 4(sp)
        ldw r10, 8(sp)
        ldw r11, 12(sp)
        addi sp, sp, INTERRUPT_STACK
        subi ea, ea, 4
        eret
        
        .text
        .global init_keyboard

init_keyboard:
        /* Initialize addresses */
        movia r9, PS2ADDR
        movia r10, KEYBOARD_INT
        movi r11, 0x55
        movi r12, 0xFA

        /* Initialize keyboard interrupts */
        /* Device */
        movia r8, 0x1
        stwio r8, 4(r9)
        /* IRQ 11 */
        rdctl r8, ctl3
        ori r8, r8, 0x800
        wrctl ctl3, r8
        /* Globally */
        movi r8, 0x1
        wrctl ctl0, r8
        
        /* Run keyboard controller self-test */
        movi r8, 0xAA
        stwio r8, 0(r9)
        /* Read the response */
wait_self_test:
        /* Wait for the interrupt to fire */
        ldb r8, 0(r10)
        beq r8, r0, wait_self_test 
        /* Load the response */
        ldb r8, 0(r10)
        /* Clear the response */
        stb r0, 0(r10)
        /* Check if the response is correct */
        beq r8, r12, passed_self_test
        /* Otherwise, return -1 */
        movi r2, -1
        ret
        
passed_self_test:       
        /* intialize caps/num/scroll lock */
        movi r8, 0xED
        stwio r8, 0(r9)
ack_init_leds1:
        /* Wait for the interrupt to fire */
        ldb r8, 0(r10)
        beq r8, r0, ack_init_leds1
        /* Load the response */
        ldb r8, 0(r10)
        /* Clear the response */
        stb r0, 0(r10)
        /* Check if the response is correct */
        beq r8, r12, passed_init_leds1
        /* Otherwise, return -1 */
        movi r2, -1
        ret

passed_init_leds1:
        /* Turn on num lock LED */
        movi r8, 0x02
        stwio r8, 0(r9)
ack_init_leds2: 
        /* Wait for the interrupt to fire */
        ldb r8, 0(r10)
        beq r8, r0, ack_init_leds2
        /* Load the response */
        ldb r8, 0(r10)
        /* Clear the response */
        stb r0, 0(r10)
        /* Check if the response is correct */        
        beq r8, r12, passed_init_leds2
        /* Otherwise, return -1 */
        movi r2, -1
        ret
        
passed_init_leds2:
        /* Keyboard initialized, return 0 */
        movi r2, 0
        ret
        