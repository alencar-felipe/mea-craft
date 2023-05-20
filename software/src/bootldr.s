.section .init
.globl bootldr

bootldr:
/* 
    li t0, 0x10000001                   // t0 = mem
    li t1, 0xDEADBEEF                   // t1 = 0xDEADBEEF
    li t2, 0xBADC0FFE                   // t2 = 0xBADC0FFE

    sw t1, 0(t0)                        // mem[0] = t1
    sw t2, 4(t0)                        // mem[1] = t2

    lw t3, 0(t0)                        // t3 = mem[0]
    beq t3, t1, 8                       // assert t3 == t1
    ebreak

    lw t4, 4(t0)                        // t4 = mem[1]
    beq t4, t2, 8                       // assert t4 == t1
    ebreak

    ebreak
*/

    la sp, _estack                  // Set the stack pointer.
    jal test_isa                    // Execute ISA test.

    la a0, greating                 // a0 = greating
    jal puts                        // puts(a0)

    li t0, 0x10000000               // Load RAM address into t0.
    jalr x0, t0, 0                  // Jump to address in t0.

puts:
    li t0, 0x30000000               // Load UART address into t0.
_puts_loop_start:
    lb t1, 0(a0)                    // t1 = *a0
    beq t1, x0, _puts_loop_end      // while(t0 != 0)
    sb t1, 0(t0)                    // *t0 = t1
    addi a0, a0, 1                  // a0 = a0 + 1
    j _puts_loop_start              // Go to loop start.
_puts_loop_end:
    ret                             // Return.

greating:
    .asciz "Greetings from Bootloader. Waiting for binary file."
