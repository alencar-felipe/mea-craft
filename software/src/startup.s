.section .init
.globl _start

_start:

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
    
    /* Execute ISA test. */

    jal test_isa
    
    /* Setup interruptions */

    li t0, 0xDEADBEEF
    csrrw x0, mtvec, t0
    
    li t0, 0x00000880
    csrrs x0, mie, t0

    li t0, 0x00000080
    csrrs x0, mstatus, t0

    /* Execute main function. */

    jal main
    
    /* End of the program. */

    ebreak