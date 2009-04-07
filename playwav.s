/* Play a sound from a wave file.  Returns 0 on success, -1 on failure. */
        
	/* Register values
	r0 0
	r1 at
	r2 Return value 1
	r3 Return value 2
	r4 Arg 1 = Wav file address
	r5 Arg 2 = 
	r6 Arg 3 = 
	r7 Arg 4

	* Can get trampled *
	r8 Temp
	r9 AUDIO_ADDR
	r10 Wav data
	r11 Number of channels
	r12 audio_cur
	r13 Bytes per sample
	r14 audio_end
	r15 Number of samples played counter

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

        .equ AUDIO_ADDR, 0xff1160
        .equ AUDIO_ENABLE, 0x2 /* 0010 */ /* Enable write interrupts */
        .equ AUDIO_DISABLE, 0x8 /* 1000 */ /* Disable interrupts, clear write FIFO's */

        .text
        .global playwav

playwav:
        movia r9, AUDIO_ADDR
        
        /* Immediately disable whatever's currently playing */
        movi r8, AUDIO_DISABLE
        stwio r8, 0(r9)
        
        /* Go through the header and make sure it's a valid wave file */
        ldw r10, 0(r4)
        addi r4, r4, 4
        /* Check for RIFF */
        movia r8, 0x52494646 /* RIFF */
        beq r10, r8, ChunkSize
        /* Else return -1 */
        movi r2, -1
        ret
        
ChunkSize:
        ldw r10, 0(r4)
        addi r4, r4, 4
        /* Load last entry in wav file into global variable */
        add r8, r10, r4
        movia r14, audio_end
        stw r8, 0(r14)

Format:
        ldw r10, 0(r4)
        addi r4, r4, 4
        movia r8, 0x57415645 /* WAVE */
        beq r10, r8, subChunk1ID
        /* Else return -1 */
        movi r2, -1
        ret

subChunk1ID:
        ldw r10, 0(r4)
        addi r4, r4, 4
        movia r8, 0x666d7420 /*fmt */
        beq r10, r8, subChunk1size
        /* Else return -1 */
        movi r2, -1
        ret

subChunk1size:
        ldw r10, 0(r4)
        addi r4, r4, 4
        movia r8, 0x10000000 /* 16 */
        beq r10, r8, subChunk1data
        /* Else return -1 */
        movi r2, -1
        ret

subChunk1data:
        /* Get the number of channels */
        ldh r11, 0(r4)
        addi r4, r4, 12 /* Skip SampleRate and ByteRate */
        srli r11, r11, 2

        /* Get the bytes per sample (BlockAlign) */
        ldw r13, 0(r4)
        addi r4, r4, 4
        srli r13, r13, 6

        /* Check the data tag */
        ldw r10, 0(r4)
        addi r4, r4, 8 /* Skip SubChunk2Size */
        movia r8, 0x64617461 /* data */
        beq r10, r8, read_data
        /* Else return -1 */
        movi r2, -1
        ret

read_data:      
        /* Now we start reading the data and filling the fifos */
        /* Rather than polling, just put 128 samples in */
        movi r15, 0
        movi r8, 128
        /* Check whether it's stereo or mono */
        subi r11, r11, 1
        /* Write num_channels -1 to audio_channels */
        movia r10, audio_channels
        stw r11, 0(r10)
        beq r11, r0, fill_write_fifo_mono

fill_write_fifo_stereo:
        ldw r10, 0(r4)
        addi r4, r4, 4
        stwio r10, 8(r9)
        ldw r10, 0(r4)
        addi r4, r4, 4
        stwio r10, 12(r9)
        addi r15, r15, 1
        bge r4, r14, end_play /* Less than 128 samples total */
        blt r15, r8, fill_write_fifo_stereo

        br enable_irq

fill_write_fifo_mono:
        ldw r10, 0(r4)
        addi r4, r4, 4
        stwio r10, 8(r9)
        stwio r10, 12(r9)
        addi r15, r15, 1
        bge r4, r14, end_play /* Less than 128 samples total */
        blt r15, r8, fill_write_fifo_mono

enable_irq:
        /* Write our stopping location to audio_cur */
        movia r12, audio_cur
        stw r4, 0(r12)
        
        /* Enable IRQ (line 12) */
        rdctl r8, ctl3
        ori r8, r8, 0x1000 /* Not SE */
        wrctl ctl3, r8

        /* Enable device write interrupts */
        movi r8, AUDIO_ENABLE
        stwio r8, 0(r9)
        
end_play:
        ret
        