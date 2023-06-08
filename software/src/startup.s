.section .text
.globl irq_handler

irq_handler:
    csrrw x0, mscratch, t0          // mscratch = t0
    csrrs t0, mcause, x0            // t0 = mcause

    beq t0, x0, start               // if mcause == reset: goto start

    csrrs t0, mscratch, x0          // t0 = mscratch

irq_handler_counter:

    /* Save registers. */

    addi sp, sp, -128
    //sw x0, 0(sp)
    sw x1, 4(sp)
    //sw x2, 8(sp)
    sw x3, 12(sp)
    sw x4, 16(sp)
    sw x5, 20(sp)
    sw x6, 24(sp)
    sw x7, 28(sp)
    sw x8, 32(sp)
    sw x9, 36(sp)
    sw x10, 40(sp)
    sw x11, 44(sp)
    sw x12, 48(sp)
    sw x13, 52(sp)
    sw x14, 56(sp)
    sw x15, 60(sp)
    sw x16, 64(sp)
    sw x17, 68(sp)
    sw x18, 72(sp)
    sw x19, 76(sp)
    sw x20, 80(sp)
    sw x21, 84(sp)
    sw x22, 88(sp)
    sw x23, 92(sp)
    sw x24, 96(sp)
    sw x25, 100(sp)
    sw x26, 104(sp)
    sw x27, 108(sp)
    sw x28, 112(sp)
    sw x29, 116(sp)
    sw x30, 120(sp)
    sw x31, 124(sp)


    /* Clear IRQ */

    li t0, 0x30010004
    lw t1, 0(t0)
    sw t1, 0(t0)

    /* Execute frame_handler */

    jal frame_handler

    /* Restore registers. */

    //lw x0, 0(sp)
    lw x1, 4(sp)
    //lw x2, 8(sp)
    lw x3, 12(sp)
    lw x4, 16(sp)
    lw x5, 20(sp)
    lw x6, 24(sp)
    lw x7, 28(sp)
    lw x8, 32(sp)
    lw x9, 36(sp)
    lw x10, 40(sp)
    lw x11, 44(sp)
    lw x12, 48(sp)
    lw x13, 52(sp)
    lw x14, 56(sp)
    lw x15, 60(sp)
    lw x16, 64(sp)
    lw x17, 68(sp)
    lw x18, 72(sp)
    lw x19, 76(sp)
    lw x20, 80(sp)
    lw x21, 84(sp)
    lw x22, 88(sp)
    lw x23, 92(sp)
    lw x24, 96(sp)
    lw x25, 100(sp)
    lw x26, 104(sp)
    lw x27, 108(sp)
    lw x28, 112(sp)
    lw x29, 116(sp)
    lw x30, 120(sp)
    lw x31, 124(sp)
    addi sp, sp, 128

    /* Return from interrupt. */

    mret

start:
    /* Set the stack pointer to the top of the memory. */
    
    la sp, _estack
    
    /* Initialize the .bss section. */

    la t0, _sbss
    la t1, _ebss
    li t2, 0
loop_start:
    beq t0, t1, loop_end
    sw t2, 0(t0)
    addi t0, t0, 4
    j loop_start
loop_end:
    
    /* Setup interruptions */

    la t0, irq_handler
    csrrw x0, mtvec, t0
    
    li t0, 0x00000800
    csrrs x0, mie, t0

    li t0, 0x00000008
    csrrs x0, mstatus, t0

    /* Execute main function. */

    jal main
    
    /* End of the program. */

    ebreak