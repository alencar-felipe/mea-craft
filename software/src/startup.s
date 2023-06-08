.section .text
.globl irq_handler

irq_handler:
    csrrw x0, mscratch, t0          // mscratch = t0
    csrrs t0, mcause, x0            // t0 = mcause

    beq t0, x0, start               // if mcause == reset: goto start

    csrrs t0, mscratch, x0          // t0 = mscratch

irq_handler_counter:

    /* Save registers. */

    addi sp, sp, -12
    sw t0, 0(sp)
    sw t1, 1(sp)
    sw t2, 2(sp)

    /* Increment value in address 4095. */

    li t0, 0x30010000
    li t1, 0x30010004
    lw t2, 0(t1)
    sw t2, 0(t1)
    sw t2, 0(t0)

    /* Restore registers. */

    lw t0, 0(sp)
    lw t1, 1(sp)
    lw t2, 2(sp)
    addi sp, sp, 12

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