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
        .equ AUDIO_ADDR, 0xff1160
        .equ AUDIO_DISABLE, 0x8 /* 1000 */ /* Disable interrupts, clear write FIFO's */

        /* Make global variables that will act as interrupt flags */
/*KEYBOARD_INT:   
        .byte 0x0
        .global KEYBOARD_INT

TIMER_INT:   
        .byte 0x0
        .global TIMER_INT
*/
        /* Exceptions section */

        .section .exceptions, "ax"
        .equ INTERRUPT_STACK, 28
        
exception_handler:
        /* Save *all* used registers to the stack */
        /* r8 = ipending */
        /* r9 = masked answer/temp */
        /* r10 = flag address */
        /* r11 = device address */
        /* r12 = audio device address */
        subi sp, sp, INTERRUPT_STACK
        stw r8, 0(sp)
        stw r9, 4(sp)
        stw r10, 8(sp)
        stw r11, 12(sp)
        stw r12, 16(sp)
        stw r13, 20(sp)
        stw r14, 24(sp)
        
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
        beq r9, r0, check_audio
        /* Acknowledge the interrupt (by clearing the timer) */
        movia r11, TIMER0_ADDR
        stwio r0, 0(r11)
        /* Set the flag */
        movia r10, TIMER_INT
        movi r9, 0x1
        stb r9, 0(r10)

check_audio:
        /* Check audio (IRQ12)*/
        andi r9, r8, 0x1000
        beq r9, r0, end_exc
        /* Fill the write FIFO again (128 samples, 75% empty,
	 * therefore 96 samples can be added) */
        /* r8 = max_samples, r9 = counter, r10 = addressval, r11 = address, 
        r12 = AUDIO_ADDR, r13 = audio_cur, r14 = audio_end */
        movi r9, 0
        movi r8, 96
        movia r12, AUDIO_ADDR
        movia r11, audio_cur
        ldw r13, 0(r11)
        movia r11, audio_end
        ldw r14, 0(r11)
        movia r11, audio_channels
        ldw r10, 0(r11)
        beq r10, r0, fill_write_fifo_mono

fill_write_fifo_stereo:
        /* Load left sample */
        ldw r10, 0(r13)
        /* Pointer arithmetic */
        addi r13, r13, 4
        /* Put it in the left channel */
        stwio r10, 8(r12)
        /* Load right sample */
        ldw r10, 0(r13)
        addi r4, r4, 4
        /* Put it in the right channel */
        stwio r10, 12(r12)
        /* Increment the counter */
        addi r9, r9, 1
        bge r13, r14, end_play /* Ran out of audio data */
        blt r9, r8, fill_write_fifo_stereo

        br end_exc

fill_write_fifo_mono:

        /* Load sample */
        ldw r10, 0(r13)
        /* Pointer arithmetic */
        addi r13, r13, 4
        /* Put it in both channels */
        stwio r10, 8(r12)
        stwio r10, 12(r12)
        /* Increment the counter */
        addi r9, r9, 1
        bge r13, r14, end_play /* Ran out of audio data */
        blt r9, r8, fill_write_fifo_stereo

        br end_exc

end_play:
        movi r8, AUDIO_DISABLE
        /* Disable the interrupt on the device */
        stwio r8, 0(r12)
        /* We're not going to worry about disabling the interrupt on the system */
        
end_exc:
        /* Restore registers */
        ldw r8, 0(sp)
        ldw r9, 4(sp)
        ldw r10, 8(sp)
        ldw r11, 12(sp)
        ldw r12, 16(sp)
        ldw r13, 20(sp)
        ldw r14, 24(sp)
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
        