.section .init
.globl bootldr

.equ RAM,   0x10000000
.equ UART,  0x30000000

/* ========================================================================== */

/*
 * @brief Bootloader entry point.
 */
bootldr:

    /* Setup stack. */
    
    la sp, _estack                  // Set the stack pointer.
    
    /* Allocate 4 bytes from the stack. */

    addi sp, sp, -4                     

    /* Execute ISA test. */

    jal test_isa                    // Call test_isa
    mv s0, a0                       // s0 = a0

    /* Print bootloader greating. */

    la a0, greatings                // a0 = greating
    jal puts                        // puts(a0)

    /* Go into distress if ISA test failed. */
    
    beq s0, x0, 8                   // if(s0 != 0)
    jal distress                    // distress(a0)

    /* Print waiting binary message. */
    
    la a0, waiting_binary           // a0 = waiting_binary
    jal puts                        // puts(a0)

    /* Read data size. */

    mv a0, sp                       // a0 = sp
    li a1, 4                        // a1 = 4
    jal read                        // read(a0, a1)
    
    /* Receive program from serial. */

    li a0, RAM                      // a0 = RAM
    lw a1, 0(sp)                    // t0 = *(sp)
    jal read                        // read(a0, a1)
    mv s0, a0                       // s0 = a0

    /* Read data checksum. */

    mv a0, sp                       // a0 = sp
    li a1, 1                        // a1 = 1
    jal read                        // read(a0, a1)

    /* Compare checksum. */

    beq a0, s0, _bootldr_fail_end   // if (a0 == s0)
_bootldr_fail_start:
    la a0, checksum_fail            // a0 = failure
    jal puts                        // puts(a0)
    ebreak                          // "halt"
_bootldr_fail_end:
    la a0, success                  // a0 = success
    jal puts                        // puts(a0)

    /* Deallocate 4 bytes from stack. */

    addi sp, sp, 4     

    /* Jump to loaded program. */

    li t0, RAM                      // Load RAM address into t0.
    jalr x0, t0, 0                  // Jump to address in t0.

/* ========================================================================== */
/*
 * @brief Prints test_isa_fail and then the raw error code in a loop
 * @param a0: error code
 */
distress:
    mv t0, a0                       // t0 = a0
    la a0, test_isa_fail            // a0 = test_isa_fail
    jal puts                        // puts(a0)

    li t1, UART                     // t1 = UART
_distress_start:                    
    sb t0, 0(t1)                    // *t1 = t0
    j _distress_start               // while(true)
_distress_end:
    ret                             // return (wont happen)

/* ========================================================================== */

/*
 * @brief Prints a null-terminated string to the UART.
 * @param a0: The null-terminated string to be printed.
 */
puts:

    /* Initialize variables. */

    li t0, UART                     // Load UART address into t0.

_puts_loop_start:

    /* Load char. */

    lb t1, 0(a0)                    // t1 = *a0

    /* Exit condition. */
    
    beq t1, x0, _puts_loop_end      // while(t1 != 0)
    
    /* Transmit data. */

    sb t1, 0(t0)                    // *t0 = t1
    
    /* Next iteration. */
    
    addi a0, a0, 1                  // a0 = a0 + 1
    j _puts_loop_start              // Go to loop start.

_puts_loop_end:

    /* Return. */

    ret                             // Return.

/* ========================================================================== */

/*
 * @brief Reads n bytes from UART into buffer.
 * @param a0: buffer
 * @param a1: n
 * @return a0: checksum
 */
read:

    /* Initialize variables. */

    li t0, UART                     // t0 = UART.
    li t1, 0                        // t1 = 0

_read_loop_start:

    /* Exit condition. */

    beq a1, x0, _read_loop_end      // while (a1 != 0)
    
    /* Read data. */

    lb t2, 0(t0)                    // t2 = *t0
    sb t2, 0(a0)                    // *a0 = t2
    
    /* Update the checksum. */

    add t1, t1, t2                  // t1 = t1 + t2
    andi t1, t1, 0xFF               // t1 = t1 % 256

    /* Next iteration. */
    
    addi a0, a0, 1                  // a0++
    addi a1, a1, -1                 // a1--               
    j _read_loop_start              // Go to loop start.

_read_loop_end:

    /* Return checksum. */

    mv a0, t1                       // a0 = t1
    ret                             // Return.

/* ========================================================================== */

greatings:
    .asciz "Greetings from Bootloader. \n"

waiting_binary:
    .asciz "Waiting for binary data. \n"

success:
    .asciz "Data received. Jumping to 0x10000000. \n"

test_isa_fail:
    .asciz "Test ISA failed. Halting. \n"

checksum_fail:
    .asciz "Checksum failed. Halting. \n"